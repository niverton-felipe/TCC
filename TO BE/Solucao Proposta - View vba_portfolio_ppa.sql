CREATE view [dbo].[vw_portfolio_ppa_performance] as 
-- Devido as necessidades do negócio, o uso do asterisco não é um problema, haja visto que 
--será necessário retornar todos os campos da subquery
select CAST(CONCAT(z.[Ano], FORMAT(z.[Data_Rel],'MM'), z.[ID_Submercado], z.[ID_Fonte]) AS int) As ID_Produto,z.* from 
(
select
  contratos.Status,
  --contratos.Valor_financeiro_atualizado,
  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE contratos.Valor_financeiro_atualizado
	   END AS Valor_financeiro_atualizado,
  --contratos.Valor_Ressarcimento,
  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE contratos.Valor_Ressarcimento
	   END AS Valor_Ressarcimento,
  (case
	WHEN iif(contratos.ID_Parte = contratos.ID_Contraparte, 1, 0) = 1 THEN 0
	ELSE iif(isNull(grupos_intrabook.agrupamento_empresa,'1')='1' AND contratos.ID_Parte <> contratos.ID_Contraparte,0,1)
  end) as Intercompany,
  contratos.[ID_Contraparte],
  contratos.[ID_Perfil_CCEE_vendedor] as [ID_Fonte],
  contratos.ID_Submercado,
  contratos.[Ano],
  contratos.[Mes],
  contratos.DT_Ini_Vig,
  contratos.DT_Fim_Vig,
  contratos.Data_Ref,
  contratos.Data_Criacao,
  contratos.data_fechamento,
  contratos.Data_publicacao,
  u.ID_UF,
  IIF(contratos.Valor_Financeiro_Realizado > 0 or contratos.Contrato_Original_Faturado = 1, 1, 0) As Contrato_Faturado,
  contratos.Nr_contrato_vinculado,
  contratos.FlexibilidadeMensalMax,
  contratos.FlexibilidadeMensalMin,
  --contratos.Valor_Financeiro_Realizado,
  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE contratos.Valor_Financeiro_Realizado
	   END AS Valor_Financeiro_Realizado,
  contratos.Suprimento_inicio,
  contratos.Suprimento_termino,
  --contratos.Quant_Contratada,
  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE contratos.Quant_Contratada
	   END AS Quant_Contratada,
  --contratos.Preco_base,
  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE contratos.Preco_base
	   END AS Preco_base,
  IIF (contratos.ID_Tipo_Contrato = 3 and contratos.ID_Tipo_Agente_Comprador = 1 and contratos.ID_Contraparte in (45445, 644642), contratos.ID_Tipo_Contrato * 1000, contratos.ID_Tipo_Contrato) as ID_Tipo_Contrato,   
  contratos.ID_Parte,
  IIF (contratos.ID_Tipo_Contrato = 3 and contratos.ID_Tipo_Agente_Comprador = 1 and contratos.ID_Contraparte in (45445, 644642), 'Bilateral - GD', contratos.Tipo_Contrato) as Tipo_Contrato, 
  horasMes.Horas,
  dateadd(day, 0, dateadd(month, contratos.[Mes]-1, dateadd(year, contratos.[ano]-1900, 0))) As [Data_Rel],
  contratos.[Cenario],
  --nivel5Nome_empresa
  coalesce(grupos.nivel5Nome_empresa, concat('#Empresa Fora da Hierarquia: ', contratos.Parte_apelido)) as Empresa_Nivel5,  
  coalesce(grupos.empresa_nome, concat('#Empresa Fora da Hierarquia: ', contratos.Parte_apelido)) as Empresa_Nivel4, 
  coalesce(grupos.agrupamento_empresa, concat('#Empresa Fora da Hierarquia: ', contratos.Parte_apelido)) as Empresa_Nivel3,
  coalesce(grupos.link2, concat('#Empresa Fora da Hierarquia: ', contratos.Parte_apelido)) as Empresa_Nivel2,
  coalesce(grupos.grupo, concat('#Empresa Fora da Hierarquia: ', contratos.Parte_apelido)) as Empresa_Nivel1,
  contratos.Movimentacao,
  contratos.Ramo_Atividade, 
  iif([Movimentacao]='Compra', [ID_Portfolio_Comprador], [ID_Portfolio_Vendedor]) as [ID_Portfolio],
  iif([Movimentacao]='Compra', [Portfolio_Comprador], [Portfolio_Vendedor]) as [Portfolio],
  contratos.ID_Fato_Contratos_196 * 10 as ID_Fato_Contratos_196,  -- Termina com 0
  contratos.ID_Fato_Contratos_196_Persist,
  contratos.Nome_Contrato,
  contratos.Codigo_Contrato as Codigo_Contrato, -- Termina com 0
  contratos.Perfil_CCEE_Vendedor as [Fonte],
  contratos.[Submercado],
  contratos.Contraparte_Apelido As [Contraparte],

  IIF (contratos.ID_Tipo_Contrato = 3 
		and contratos.ID_Tipo_Agente_Comprador = 1 
		and contratos.ID_Contraparte in (45445, 644642), 'ACR', 
	iif(contratos.[Tipo_contrato]='Bilateral', 'ACL', 'ACR')) as [Ambiente],

  contratos.Segmento_Mercado,
  contratos.Regra_Preco,
  contratos.Form_Agio,
  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE iif(contratos.ID_Tipo_Contrato = 55, 
			nullif(COALESCE(contratos.QuantAtualizada, contratos.[Quant_Sazonalizada], contratos.quant_contratada),1) ,
			QuantAtualizada) 
	   END as [Quantidade_MWh],
  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE iif(contratos.ID_Tipo_Contrato = 55, 
			nullif(COALESCE(contratos.QuantAtualizada, contratos.[Quant_Sazonalizada], contratos.quant_contratada),1) ,
			QuantAtualizada) / horasMes.horas 
	   END as [Quantidade_MWm],
  iif(contratos.ID_Parte = contratos.ID_Contraparte, 1, 0) as Intrabook
from

/*
Apesar do uso de alguns subselects que poderiam ser evitados, o principal problema desta view consiste
em consultar a tabela de contratos de maneira histórica. Ou seja, será necessário retornar 
um alto volume de dados. Logo, o tempo de recuperação da query será muito grande. Para solucionar esse caso, substituiremos a tabela fato original pela tabela fato com quantidade de histórico recente e que satisfará a necessidade do negócio
*/
  ((--Fato_Contratos_196 contratos tabela original
        Materializacoes.Fato_Contratos_196_Staging contratos
        left join portfolio_grupos grupos on contratos.Id_parte=grupos.nivel5Id_empresa)
        left join tabela_horas horasMes on dateadd(day, 0, dateadd(month, contratos.[Mes]-1, dateadd(year, contratos.[ano]-1900, 0))) = dateadd(day, 0, dateadd(month, horasMes.[Mês]-1, dateadd(year, horasMes.[ano]-1900, 0))))
        left join portfolio_grupos grupos_intrabook on contratos.Id_contraparte=grupos_intrabook.nivel5Id_empresa
		left join dUF u  on u.UF = contratos.Parte_Estado
where 

  contratos.ID_Tipo_Contrato <> 99  AND
  contratos.Ano >= 2020 and 
  contratos.ID_Status<>1
  and (contratos.Valor_Financeiro_Realizado > 0 or contratos.status <> 'Rescindido' or contratos.Contrato_Original_Faturado = 1)
    and epai <> 1  -- remove os contratos pais do join
  and not ((contratos.[Ano] > 2020 OR (contratos.[Ano] = 2019 AND contratos.[Mes] > 5 ))
  and contratos.[ID_Parte] IN (756, 1205, 1206, 1207, 1208, 1209, 1210, 1218, 1219, 1220, 1221, 1226, 1227, 1229, 730, 728))


/*
Além disso, essa consulta a tabela histórica é feita duas vezes nesta view.
*/

union all

/* Mesma query que a de cima porém quando for 'venda' vira 'compra' e 'compra' vira 'venda' 
  Isto serve para considerar as duas pontas de Intrabooks */ 

select 
  contratos.Status,
  --contratos.Valor_financeiro_atualizado,
  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE contratos.Valor_financeiro_atualizado
	   END AS Valor_financeiro_atualizado,
  --contratos.Valor_Ressarcimento,
  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE contratos.Valor_Ressarcimento
	   END AS Valor_Ressarcimento,
  (case
	WHEN iif(contratos.ID_Parte = contratos.ID_Contraparte, 1, 0) = 1 THEN 0
	ELSE iif(isNull(grupos_intrabook.agrupamento_empresa,'1')='1' AND contratos.ID_Parte <> contratos.ID_Contraparte,0,1)
  end) as Intercompany,
  contratos.[ID_Contraparte],
  contratos.[ID_Perfil_CCEE_Vendedor] as [ID_Fonte],
  contratos.ID_Submercado,
  contratos.[Ano],
  contratos.[Mes],
  contratos.DT_Ini_Vig,
  contratos.DT_Fim_Vig,
  contratos.Data_ref,
  contratos.Data_Criacao,
  contratos.data_fechamento,
  contratos.Data_publicacao,
  u.ID_UF,
  IIF(contratos.Valor_Financeiro_Realizado > 0 or contratos.Contrato_Original_Faturado = 1, 1, 0) As Contrato_Faturado,
  contratos.Nr_contrato_vinculado,
  contratos.FlexibilidadeMensalMax,
  contratos.FlexibilidadeMensalMin,
  --contratos.Valor_Financeiro_Realizado,
  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE contratos.Valor_Financeiro_Realizado
	   END AS Valor_Financeiro_Realizado,
  contratos.Suprimento_inicio,
  contratos.Suprimento_termino,
  --contratos.Quant_Contratada,
  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE contratos.Quant_Contratada
	   END AS Quant_Contratada,
  --contratos.Preco_base,
  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE contratos.Preco_base
	   END AS Preco_base,
  IIF (contratos.ID_Tipo_Contrato = 3 and contratos.ID_Tipo_Agente_Comprador = 1 and contratos.ID_Contraparte in (45445, 644642), contratos.ID_Tipo_Contrato * 1000, contratos.ID_Tipo_Contrato) as ID_Tipo_Contrato,   
  contratos.ID_Parte,
  IIF (contratos.ID_Tipo_Contrato = 3 and contratos.ID_Tipo_Agente_Comprador = 1 and contratos.ID_Contraparte in (45445, 644642), 'Bilateral - GD', contratos.Tipo_Contrato) as Tipo_Contrato, 
  horasMes.Horas,
  dateadd(day, 0, dateadd(month, contratos.[Mes]-1, dateadd(year, contratos.[ano]-1900, 0))) As [Data_Rel],
  contratos.[Cenario],
  coalesce(grupos.nivel5Nome_empresa, concat('#Empresa Fora da Hierarquia: ', contratos.Parte_apelido)) as Empresa_Nivel5,
  coalesce(grupos.empresa_nome, concat('#Empresa Fora da Hierarquia: ', contratos.Parte_apelido)) as Empresa_Nivel4, 
  coalesce(grupos.agrupamento_empresa, concat('#Empresa Fora da Hierarquia: ', contratos.Parte_apelido)) as Empresa_Nivel3,
  coalesce(grupos.link2, concat('#Empresa Fora da Hierarquia: ', contratos.Parte_apelido)) as Empresa_Nivel2,
  coalesce(grupos.grupo, concat('#Empresa Fora da Hierarquia: ', contratos.Parte_apelido)) as Empresa_Nivel1,
  iif(contratos.Movimentacao='Compra', 'Venda', 'Compra') as [Movimentacao], -- inverte essa ponta
  contratos.Ramo_Atividade,
  iif([Movimentacao]='Compra', [ID_Portfolio_Vendedor], [ID_Portfolio_Comprador]) as [ID_Portfolio], -- inverte essa ponta
  iif([Movimentacao]='Compra', [Portfolio_Vendedor], [Portfolio_Comprador]) as [Portfolio], -- inverte essa ponta
  contratos.ID_Fato_Contratos_196 * 10 + 1 as ID_Fato_Contratos_196, -- Termina com 1
  contratos.ID_Fato_Contratos_196_Persist,
  contratos.Nome_contrato, 
  contratos.Codigo_Contrato + 1 as Codigo_Contrato, -- Termina com 1
  contratos.[Perfil_CCEE_Vendedor] as [Fonte],
  contratos.[Submercado], 
  contratos.Contraparte_apelido as [Contraparte], 
  --iif(contratos.[Tipo_contrato]='Bilateral', 'ACL', 'ACR') as [Ambiente],

  IIF (contratos.ID_Tipo_Contrato = 3 
		and contratos.ID_Tipo_Agente_Comprador = 1 
		and contratos.ID_Contraparte in (45445, 644642), 'ACR', 
	iif(contratos.[Tipo_contrato]='Bilateral', 'ACL', 'ACR')) as [Ambiente],

  contratos.Segmento_Mercado, 
  contratos.Regra_Preco,
  contratos.Form_Agio,

  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE iif(contratos.ID_Tipo_Contrato = 55, 
			nullif(COALESCE(contratos.QuantAtualizada, contratos.[Quant_Sazonalizada], contratos.quant_contratada),1) ,
			QuantAtualizada) 
	   END as [Quantidade_MWh],
  CASE WHEN (contratos.Ano >= 2022 AND contratos.Mes >= 9 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
		 OR (contratos.Ano > 2022 AND contratos.Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454))
	   THEN 0
	   ELSE iif(contratos.ID_Tipo_Contrato = 55, 
			nullif(COALESCE(contratos.QuantAtualizada, contratos.[Quant_Sazonalizada], contratos.quant_contratada),1) ,
			QuantAtualizada) / horasMes.horas 
	   END as [Quantidade_MWm],

  iif(contratos.ID_Parte = contratos.ID_Contraparte, 1, 0) as Intrabook
from 
  ((--Fato_Contratos_196 contratos --
         Materializacoes.Fato_Contratos_196_Staging contratos
        left join portfolio_grupos grupos on contratos.Id_parte=grupos.nivel5Id_empresa) 
        left join tabela_horas horasMes on dateadd(day, 0, dateadd(month, contratos.[Mes]-1, dateadd(year, contratos.[ano]-1900, 0))) 
		= dateadd(day, 0, dateadd(month, horasMes.[Mês]-1, dateadd(year, horasMes.[ano]-1900, 0)))
        left join portfolio_grupos grupos_intrabook on contratos.Id_contraparte=grupos_intrabook.nivel5Id_empresa)  
		left join dUF u  on u.UF = contratos.Parte_Estado

where 
  
  contratos.ID_Parte = contratos.ID_Contraparte and 
  contratos.ID_Tipo_Contrato <> 99  and
  contratos.Ano >= 2020 and 
  contratos.ID_Status<>1 
  and (contratos.Valor_Financeiro_Realizado > 0 or contratos.status <> 'Rescindido' or contratos.Contrato_Original_Faturado = 1)
  and epai <> 1 -- remove os contratos filhos do join

) z
GO


