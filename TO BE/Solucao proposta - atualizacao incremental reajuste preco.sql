
CREATE PROCEDURE [P_Atualizar_Tabela_Materializada_Reajuste_Preco] AS


-- Seleciona apenas os dados que n�o est�o na tabela destino
SELECT *
INTO #reajuste_preco
FROM [vw_reajuste_preco] t_view

WHERE NOT EXISTS (
	SELECT 1 FROM VBA_v_reajustePreco_ t_mat
	WHERE t_view.ID_Reajuste_preco = t_mat.ID_Reajuste_preco
)

--Seleciona registro que possuem vig�ncia aberta na tabela destino, que possuem vers�o mais recente do dado e que precisam ter vig�ncia fechada.
SELECT DISTINCT
t_mat.ID_Reajuste_preco
INTO #TEMP_REGISTROS_MODIFICADOS
FROM dbo.vw_reajustePreco_mat AS t_mat

-- Join nos dados de vigencia aberta com o mesmo ID_PERSIST 
INNER JOIN #reajuste_preco AS t_view

ON t_mat.ID_Contratos_196_Persist = t_view.ID_Contratos_196_Persist 
AND t_view.Cenario = t_mat.Cenario
AND t_view.DT_Fim_Vig = '9999-12-31'
AND t_mat.DT_Fim_Vig = '9999-12-31'

-- Retorna apenas os dados que tenham modifica��es (diferentes IDs �nicos)
WHERE t_view.ID_Reajuste_preco <> t_mat.ID_Reajuste_preco


-- Encerra a vig�ncia dos dados que tenham vers�o mais recente

UPDATE t_mat

SET t_mat.DT_Fim_Vig = origem.Dt_Fim_Vig
FROM dbo.vw_reajustePreco_mat AS t_mat

-- Join nos dados que foram modificados
INNER JOIN #TEMP_REGISTROS_MODIFICADOS AS t_view

ON t_view.ID_Reajuste_preco = t_mat.ID_Reajuste_preco
--join nos dados na fonte prim�ria dos dados para pegar a data fim vigencia mais confi�vel
INNER JOIN Fato_Reajuste_Preco_Atual origem

ON origem.ID_Reajuste_preco = ROUND((t_mat.ID_Reajuste_preco) / 10, 0)



--Seleciona dados da view vw_reajuste_preco que est�o com a vig�ncia fechada e que tiveram dt_fim_vig
-- nos �ltimos 15 dias
SELECT 
A.ID_Reajuste_preco,
A.DT_Fim_Vig
INTO #TEMP_PPA_PORTAL
FROM [vw_reajuste_preco] A
WHERE DT_Fim_Vig > CONVERT(DATE, GETDATE() -15)
AND DT_Fim_Vig <> '9999-12-31'


CREATE CLUSTERED INDEX IC_ID_VBA_CONTRATOS_196
ON #TEMP_PPA_PORTAL (ID_Reajuste_preco) 

--Altera a data de vig�ncia da tabela materializada de reajuste de pre�o que foram encerrados na VBA contratos e n�o receberam nova vig�ncia. 
UPDATE A
SET DT_Fim_Vig = B.DT_Fim_Vig
FROM dbo.vw_reajustePreco_mat A
INNER JOIN #TEMP_PPA_PORTAL B
ON A.ID_Reajuste_preco = B.ID_Reajuste_preco
WHERE A.DT_Fim_Vig <> B.DT_Fim_Vig


-- Insere os dados cujo ID �nico n�o est�o na tabela materializada
INSERT INTO vw_reajustePreco_mat 

SELECT *
FROM #reajuste_preco



DROP TABLE #reajuste_preco;

