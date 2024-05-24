
CREATE view [dbo].[vw_reajuste_preco] as

select
  Data_Rel,
  ID_Fato_Contratos_196 * 10 as ID_Fato_Contratos_196, -- Termina com 0
  Codigo_Contrato, 
  Cenario,
  --Preco_atualizado as preco_atualizado, --r.Preco_Atualizado,
  CASE WHEN Data_Rel >= '2022-09-01' AND Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454)
	   THEN 0
	   ELSE Preco_atualizado 
  END as preco_atualizado,
  --Preco_atualizado_real,
  CASE WHEN Data_Rel >= '2022-09-01' AND Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454)
	   THEN 0
	   ELSE Preco_atualizado_real
  END as Preco_atualizado_real,
  DT_Ini_Vig,
  DT_Fim_Vig,
  ID_Fato_Contratos_196_Persist
from
	dbo.Fato_Reajuste_Preco_Atual

/*
Apesar de não utilizar a tabela fato de contratos como a origem dos dados, a view utiliza outra
tabela com grande volume de dados e novamente precisa retornar esses dados para atender os requisitos
da solução que foi projetada.
*/
where

  ID_Tipo_Contrato <> 99 AND
  Data_Rel >= DATEFROMPARTS(2019, 1, 1) AND
  ID_Status <> 1 
  and (Valor_Financeiro_Realizado > 0 or ID_status <> 10 or Contrato_Original_Faturado = 1)

  and not (Data_Rel > DATEFROMPARTS(2019, 5, 1)
  and [ID_Parte] IN (674746, 64746464,646484,6464639))

/*Além disto, a consulta precisa acessar a tabela fato de reajuste de preço duas vezes */
-- segunda parte com intrabook
union all

select
  Data_Rel,
  ID_Fato_Contratos_196 * 10 + 1 as ID_Fato_Contratos_196, -- Termina com 1
  Codigo_Contrato + 1 as Codigo_Contrato, 
  Cenario,
  --Preco_atualizado as preco_atualizado, --r.Preco_Atualizado,
  CASE WHEN Data_Rel >= '2022-09-01' AND Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454)
	   THEN 0
	   ELSE Preco_atualizado 
  END as preco_atualizado,
  --Preco_atualizado_real,
  CASE WHEN Data_Rel >= '2022-09-01' AND Codigo_Contrato IN (10442353553, 55355353, 5335532332, 3523352, 53353334, 235535532, 3523454)
	   THEN 0
	   ELSE Preco_atualizado_real 
  END as Preco_atualizado_real,
  DT_Ini_Vig,
  DT_Fim_Vig,
  ID_Fato_Contratos_196_Persist
from 
	dbo.Fato_Reajuste_Preco_Atual
where 
  ID_Parte = ID_Contraparte and 
  ID_Tipo_Contrato <> 99 AND
  Data_Rel >= DATEFROMPARTS(2019, 1, 1) AND
  ID_Status <> 1 
  and (Valor_Financeiro_Realizado > 0 or ID_status <> 10 or Contrato_Original_Faturado = 1)
  
GO


