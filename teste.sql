IF OBJECT_ID('dbo.Orc_Spr_Sel_Consulta_Personalizada_Revistoria') IS NULL
	EXEC sp_executesql @statement = N'CREATE PROCEDURE dbo.Orc_Spr_Sel_Consulta_Personalizada_Revistoria AS SET NOCOUNT ON;'
GO

-- ==============================================================================
--SISTEMA:		ORION ORÇAMENTOS
--AUTOR:		Autor
--OBJETO:		Orc_Spr_Sel_Consulta_Personalizada_Revistoria
--VERSÃO:		ORCA_6.00.00.012
--DATA:			20/06/2016
--DESCRIÇÃO:	Consultar processos Revistoria
--OBSERVAÇÃO:	Informações Adicionais
--APROVADOR:	Responsável pela Aprovação do Processo
--HOMOLOGADO:	Reponsável pela Homologação
-- ==============================================================================='
-- ALTERACOES REALIZADAS NA PROCEDURE											  '	                                 
-- ==============================================================================='
--MANUTENCAO:	MANUTENCAO
--AUTOR:		AUTOR
--DATA:			DATA
-- ==============================================================================
ALTER PROCEDURE [dbo].[Orc_Spr_Sel_Consulta_Personalizada_Revistoria] @Id_Chave AS VARCHAR(080)
	,@Dt_Inicial AS VARCHAR(019) = ''
	,@Dt_Final AS VARCHAR(019) = ''
	,@Tp_Consulta AS VARCHAR(002) = ''
	,@F_Nr_Sinistro AS VARCHAR(080) = ''
	,@F_Nr_Aviso AS VARCHAR(080) = ''
	,@F_Placa AS VARCHAR(080) = ''
	,@F_Chassi AS VARCHAR(080) = ''
	,@F_Oficina AS VARCHAR(080) = ''
	,@F_UF AS VARCHAR(080) = ''
	,@F_Cidade AS VARCHAR(080) = ''
	,@F_Classe AS VARCHAR(080) = ''
	,@F_Carimbo AS VARCHAR(080) = ''
	,@F_Marca AS INT = 0
	,@F_Tp_Vistoria AS INT = 0
	,@F_Ponto_Impacto AS VARCHAR(080) = ''
	,@F_Estimativa AS DECIMAL(15, 2) = 0.0
	,@F_Fornecimento AS DECIMAL(15, 2) = 0.0
	,@Tp_Situacao AS VARCHAR(002) = '0'
AS
BEGIN
	SET NOCOUNT ON

	--select * from Web_Sessao order by Dt_Inicio_Login desc
	--declare @Id_Chave		AS VARCHAR(080) = 'ecef14b4-97d1-4fb0-8984-bf7ca32288dc'
	--declare	@Dt_Inicial		AS VARCHAR(019) = '2016-05-01' 
	--declare	@Dt_Final		AS VARCHAR(019) = '2016-06-30'
	--declare	@Tp_Consulta	AS VARCHAR(002) = 'R'
	DECLARE @Vl_Inicial AS DECIMAL(15, 02)
	DECLARE @Vl_Final AS DECIMAL(15, 02)
	DECLARE @Nr_Cpf_Cgc_Sgd AS VARCHAR(20)
	DECLARE @Nr_Cpf_Cgc_Local AS VARCHAR(20)
	DECLARE @Nr_Cpf_Cgc_Usr AS VARCHAR(20)
	DECLARE @Tp_Usuario AS INT
	DECLARE @Id_Ponto_Impacto AS INT
	DECLARE @Id_Situacao_Envio_0 AS INT
	DECLARE @Id_Situacao_Envio_1 AS INT
	DECLARE @Id_Situacao_Envio_2 AS INT
	DECLARE @Id_Situacao_Envio_3 AS INT
	DECLARE @Id_Situacao_Envio_4 AS INT
	DECLARE @Id_Situacao_Envio_5 AS INT
	DECLARE @Id_Situacao_Envio_6 AS INT
	DECLARE @M_DT_INICIO AS SMALLDATETIME
	DECLARE @M_DT_FIM AS SMALLDATETIME
	DECLARE @M_DT_HOJE AS SMALLDATETIME
	DECLARE @Id_Orcamento_0 AS TINYINT
	DECLARE @Id_Orcamento_1 AS TINYINT
	DECLARE @Id_Todos_Carimbos AS TINYINT
	DECLARE @Id_Todos_Dias AS TINYINT
	DECLARE @Nm_Reguladora AS VARCHAR(50)
	DECLARE @Id_Notas_Recebidas AS TINYINT
	DECLARE @Id_Libera_Reparos AS TINYINT
	DECLARE @Tp_Modulo AS INT
	DECLARE @SEPARADOR AS VARCHAR(02)

	SET @SEPARADOR = '||'
	SET @Tp_Usuario = 0
	SET @Id_Notas_Recebidas = NULL

	EXEC dbo.Orc_Spr_Sel_Web_Sessao @Id_Chave = @Id_Chave
		,@Nr_Cpf_Cgc_Sgd = @Nr_Cpf_Cgc_Sgd OUTPUT
		,@Nr_Cpf_Cgc_Local = @Nr_Cpf_Cgc_Local OUTPUT
		,@Nr_Cpf_Cgc_Usr = @Nr_Cpf_Cgc_Usr OUTPUT

	EXEC dbo.Orc_Spr_Upd_Web_Sessao_Controle_Sinistro @Id_Chave = @Id_Chave
		,@Id_Usuario = 0

	IF @Tp_Consulta = 'D' -- VISTORIAS RECEBIDAS DA SEGURADORA / PARA PROCESSO DE REVISTORIA
	BEGIN
		SET @Id_Situacao_Envio_1 = 1
		SET @Id_Situacao_Envio_2 = 6
		SET @Id_Situacao_Envio_3 = 16 ----REJEITADO PELA REVISTORIADORA
		SET @Id_Orcamento_0 = 0
		SET @Id_Orcamento_1 = 1
		SET @Id_Todos_Carimbos = 1
		SET @Id_Todos_Dias = 1
	END
	ELSE IF @Tp_Consulta = 'R' -- VISTORIAS DISTRIBUIDAS PELA SEGURADORA
	BEGIN
		SET @Id_Situacao_Envio_0 = 0
		SET @Id_Situacao_Envio_1 = 7
		SET @Id_Situacao_Envio_2 = 8
		SET @Id_Situacao_Envio_3 = 2
		SET @Id_Situacao_Envio_4 = 15 ----ACEITADO PELA REVISTORIADORA
		SET @Id_Situacao_Envio_5 = 17 ----FINALIZADO PELA REVISTORIADORA
		SET @Id_Situacao_Envio_6 = 6
		SET @Id_Orcamento_0 = 0
		SET @Id_Orcamento_1 = 1
		SET @Id_Todos_Carimbos = 1
		SET @Id_Todos_Dias = 1
	END
	ELSE IF @Tp_Consulta = 'F' -- VISTORIAS FINALIZADAS PELA VISTORIADORAS
	BEGIN
		SET @Id_Situacao_Envio_1 = 0
		SET @Id_Situacao_Envio_2 = 1
		SET @Id_Situacao_Envio_3 = 6
		SET @Id_Situacao_Envio_4 = 19
		SET @Id_Situacao_Envio_5 = 17
		SET @Id_Situacao_Envio_6 = 18
		SET @Id_Orcamento_0 = 0
		SET @Id_Orcamento_1 = 1
		SET @Id_Todos_Carimbos = 1
		SET @Id_Todos_Dias = 1
	END

	SELECT @Tp_Modulo = Vl_Int_Cfg
	FROM Web_Configuracoes
	WHERE Cd_Cfg = 2

	SELECT @Tp_Usuario = ISNULL(Tp_Usuario, 0)
	FROM Usuario WITH (NOLOCK)
	WHERE Nr_Cpf_Cgc_Sgd = @Nr_Cpf_Cgc_Sgd
		AND Nr_Cpf_Cgc_Usr = @Nr_Cpf_Cgc_Usr

	SELECT @Id_Ponto_Impacto = ISNULL(Id_Ponto_Impacto, 0)
		,@Nm_Reguladora = Nm_Fantasia
	FROM Seguradora WITH (NOLOCK)
	WHERE Nr_Cpf_Cgc_Sgd = @Nr_Cpf_Cgc_Sgd

	--FORMATA DATA PARA CONSULTA
	SET @Dt_Inicial = CONVERT(VARCHAR(10), LEFT(@Dt_Inicial, 10), 111) + ' 00:00:00'
	SET @Dt_Final = CONVERT(VARCHAR(10), LEFT(@Dt_Final, 10), 111) + ' 23:59:59'

	--DELETA A CONSULTA PERSONALIZADA PARA INCLUIR NOVAMENTE
	EXEC dbo.Orc_Spr_Del_Perfil_Consultas @Id_Chave = @Id_Chave
		,@Tp_Filtro = 5

	EXEC dbo.Orc_Spr_Ins_Perfil_Consultas @Id_Chave = @Id_Chave
		,@Tp_Filtro = 5
		,@Vl_Pesquisa_1 = @Dt_Inicial
		,@Vl_Pesquisa_2 = @Dt_Final

	SELECT @Vl_Inicial = CONVERT(DECIMAL(15, 02), REPLACE(REPLACE(ISNULL(Vl_Pesquisa_1, 0), '.', ''), ',', '.'))
		,@Vl_Final = CONVERT(DECIMAL(15, 02), REPLACE(REPLACE(ISNULL(Vl_Pesquisa_2, 0), '.', ''), ',', '.'))
	FROM Web_Perfil_Consultas
	WHERE Nr_Cpf_Cgc_Sgd = @Nr_Cpf_Cgc_Sgd
		AND Nr_Cpf_Cgc_Local = @Nr_Cpf_Cgc_Local
		AND Nr_Cpf_Cgc_Usr = @Nr_Cpf_Cgc_Usr
		AND Tp_Filtro = 4

	DECLARE @Cd_Carimbo_Aprova_Rev AS INT
	DECLARE @Cd_Carimbo_Reprova_Rev AS INT
	DECLARE @Cd_Carimbo_Aprova_Orc AS INT
	DECLARE @Cd_Carimbo_Reprova_Orc AS INT
	DECLARE @Cd_Carimbo_Finaliza_Rev AS INT

	---Carrego os carimbos de reprovação e aprovação
	SELECT @Cd_Carimbo_Aprova_Rev = Vl_Int_Cfg
	FROM Web_Configuracoes_Seguradora WITH (NOLOCK)
	WHERE Nr_Cpf_Cgc_Sgd = @Nr_Cpf_Cgc_Sgd
		AND Cd_Cfg = 6003

	SELECT @Cd_Carimbo_Reprova_Rev = Vl_Int_Cfg
	FROM Web_Configuracoes_Seguradora WITH (NOLOCK)
	WHERE Nr_Cpf_Cgc_Sgd = @Nr_Cpf_Cgc_Sgd
		AND Cd_Cfg = 6004

	SELECT @Cd_Carimbo_Aprova_Orc = Vl_Int_Cfg
	FROM Web_Configuracoes_Seguradora WITH (NOLOCK)
	WHERE Nr_Cpf_Cgc_Sgd = @Nr_Cpf_Cgc_Sgd
		AND Cd_Cfg = 6005

	SELECT @Cd_Carimbo_Reprova_Orc = Vl_Int_Cfg
	FROM Web_Configuracoes_Seguradora WITH (NOLOCK)
	WHERE Nr_Cpf_Cgc_Sgd = @Nr_Cpf_Cgc_Sgd
		AND Cd_Cfg = 6006

	SELECT @Cd_Carimbo_Finaliza_Rev = Vl_Int_Cfg
	FROM Web_Configuracoes_Seguradora WITH (NOLOCK)
	WHERE Nr_Cpf_Cgc_Sgd = @Nr_Cpf_Cgc_Sgd
		AND Cd_Cfg = 6007

	IF @Vl_Inicial > @Vl_Final
		SET @Vl_Final = @Vl_Inicial
	SET @M_DT_INICIO = @Dt_Inicial
	SET @M_DT_FIM = @Dt_Final
	SET @M_DT_HOJE = CONVERT(VARCHAR(10), GETDATE(), 111) + ' 00:00:00'
	SET NOCOUNT OFF

	SELECT SMA.Nm_Sgd AS Nm_Seg
		,SMA.Nm_Oficina
		,OFI.Nm_Cidade
		,OFI.Cd_UF
		,SMA.Ds_Veiculo
		,SMA.Nr_Sinistro
		,SMA.Nr_Aviso_Sinistro
		,SMA.Nm_Perito
		,Nm_Usr_Registro AS Nm_Usr_Atual
		,RIGHT('0' + CONVERT(VARCHAR(002), DATEPART(DAY, SMA.Dt_Vistoria)), 2) + '/' + RIGHT('0' + CONVERT(VARCHAR(002), DATEPART(MONTH, SMA.Dt_Vistoria)), 2) + '/' + CONVERT(VARCHAR(004), DATEPART(YEAR, SMA.Dt_Vistoria)) AS Agendamento
		,CONVERT(VARCHAR(004), DATEPART(YEAR, SMA.Dt_Vistoria)) + RIGHT('0' + CONVERT(VARCHAR(002), DATEPART(MONTH, SMA.Dt_Vistoria)), 2) + RIGHT('0' + CONVERT(VARCHAR(002), DATEPART(DAY, SMA.Dt_Vistoria)), 2) AS Agendamento2
		,
		--        RIGHT( '0' + CONVERT(VARCHAR(002),DATEPART(DAY,SMA.Dt_Atlz_Registro)),2)    + '/' +       
		--        RIGHT( '0' + CONVERT(VARCHAR(002),DATEPART(MONTH,SMA.Dt_Atlz_Registro)),2)  + '/' +       
		--        CONVERT(VARCHAR(004),DATEPART(YEAR,SMA.Dt_Atlz_Registro))                   + ' ' +       
		--        RIGHT( '0' + CONVERT(VARCHAR(002),DATEPART(HOUR,SMA.Dt_Atlz_Registro)),2)   + ':' +       
		--        RIGHT( '0' + CONVERT(VARCHAR(002),DATEPART(MINUTE,SMA.Dt_Atlz_Registro)),2)         AS Atualizado,  
		SMA.Dt_Atlz_Registro AS Atualizado
		,CONVERT(VARCHAR(004), DATEPART(YEAR, SMA.Dt_Atlz_Registro)) + RIGHT('0' + CONVERT(VARCHAR(002), DATEPART(MONTH, SMA.Dt_Atlz_Registro)), 2) + RIGHT('0' + CONVERT(VARCHAR(002), DATEPART(DAY, SMA.Dt_Atlz_Registro)), 2) + ' ' + RIGHT('0' + CONVERT(VARCHAR(002), DATEPART(HOUR, SMA.Dt_Atlz_Registro)), 2) + ':' + RIGHT('0' + CONVERT(VARCHAR(002), DATEPART(MINUTE, SMA.Dt_Atlz_Registro)), 2) AS Atualizado2
		,SMA.Ds_Carimbo
		,Classe = CASE 
			WHEN SMA.Nr_Seq_Pasta = 1
				OR SMA.Nr_Seq_Pasta = 201
				THEN 'SEGURADO'
			WHEN (
					SMA.Nr_Seq_Pasta > 1
					AND SMA.Nr_Seq_Pasta < 200
					)
				OR (SMA.Nr_Seq_Pasta > 201)
				THEN 'TERCEIRO'
			END
		,Cd_Chassi = CASE 
			WHEN SMA.Nr_Seq_Pasta = 1
				OR SMA.Nr_Seq_Pasta = 201
				THEN SMA.Cd_Chassi_Seg
			WHEN (
					SMA.Nr_Seq_Pasta > 1
					AND SMA.Nr_Seq_Pasta < 200
					)
				OR (SMA.Nr_Seq_Pasta > 201)
				THEN ISNULL(SMA.Cd_Chassi_Terc, '')
			END
		,SMA.Nr_Placa
		,Icone = CASE 
			WHEN (
					SMA.Id_Situacao_Envio IN (6)
					AND @Tp_Usuario IN (22)
					)
				THEN 'ABRIR'
			WHEN (
					SMA.Id_Situacao_Envio NOT IN (
						2
						,5
						,6
						)
					OR @Tp_Usuario NOT IN (
						6
						,7
						)
					)
				AND SMA.Cd_Chassi_Orc IS NULL
				THEN 'BRANCO'
			WHEN (
					SMA.Id_Situacao_Envio IN (
						2
						,5
						,6
						)
					OR @Tp_Usuario IN (
						6
						,7
						)
					)
				THEN 'NPE'
			ELSE 'ABRIR'
			END
		,Orcamento = CASE 
			WHEN SMA.Id_Orcamento = 1
				THEN 'SIM'
			ELSE 'NAO'
			END
		,Ponto_Impacto = CASE 
			WHEN SMA.Id_Ponto_Impacto = 1
				THEN 'SIM'
			ELSE 'NAO'
			END
		,IconePontoImpacto = CASE 
			WHEN SMA.Id_Orcamento <> 1
				THEN 'VEICULOAUSENTE'
			WHEN SMA.Id_Orcamento = 1
				AND SEG.Id_Ponto_Impacto <> 1
				THEN 'SEMPIMPACTO'
			WHEN SMA.Id_Orcamento = 1
				AND SEG.Id_Ponto_Impacto = 1
				AND @Tp_Usuario NOT IN (
					6
					,7
					)
				AND SMA.Id_Situacao_Envio NOT IN (
					2
					,5
					,6
					)
				THEN 'PIMPACTO'
			ELSE 'SEMPIMPACTO'
			END
		,CONVERT(VARCHAR(20), RTRIM(SMA.Cd_Chassi_Seg)) + @SEPARADOR + CONVERT(VARCHAR(19), SMA.Dt_Inicio_Vigencia, 121) + @SEPARADOR + CONVERT(VARCHAR(18), RTRIM(SMA.Nr_Endosso)) + @SEPARADOR + CONVERT(VARCHAR(19), SMA.Dt_Hr_Sinistro, 121) + @SEPARADOR + CONVERT(VARCHAR(03), SMA.Nr_Seq_Pasta) + @SEPARADOR + CONVERT(VARCHAR(20), RTRIM(ISNULL(SMA.Cd_Chassi_Orc, ''))) + @SEPARADOR + CONVERT(VARCHAR(05), ISNULL(SMA.Nr_Orc, '0')) + @SEPARADOR AS CHAVE
		,Aberto = CASE 
			WHEN SMA.Id_Situacao_Envio = 8
				AND @Nr_Cpf_Cgc_Sgd = SMA.Cd_Perito
				THEN 'SIMSE'
			WHEN SMA.Id_Situacao_Envio = 8
				AND @Nr_Cpf_Cgc_Sgd <> SMA.Cd_Perito
				THEN 'SIMPE'
			WHEN SMA.Id_Situacao_Envio <> 8
				AND @Nr_Cpf_Cgc_Sgd = SMA.Cd_Perito
				THEN 'NAOSE'
			WHEN SMA.Id_Situacao_Envio <> 8
				AND @Nr_Cpf_Cgc_Sgd <> SMA.Cd_Perito
				THEN 'NAOPE'
			END
		,Id_VA = CASE 
			WHEN SMA.Id_Orcamento <> 1
				AND @Tp_Consulta IN (
					'RS'
					,'NR'
					)
				THEN 'SIM'
			ELSE 'NAO'
			END
		,Reabrir = CASE 
			WHEN SMA.Id_Situacao_Envio = 5
				AND ISNULL(REA.Vl_Int_Cfg, 0) IN (
					8
					,9
					,10
					,11
					,12
					,13
					,14
					,15
					)
				AND @Tp_Usuario NOT IN (
					6
					,7
					)
				THEN 'SIM'
			ELSE 'NAO'
			END
		,SMA.Id_Situacao_Envio
		,Url_Reabertura = (
			SELECT Vl_Str_Cfg
			FROM Web_Configuracoes_Seguradora WCS WITH (NOLOCK)
			WHERE WCS.Nr_Cpf_Cgc_Sgd = SMA.Nr_Cpf_Cgc_Sgd
				AND WCS.Cd_Cfg = 34
			)
		,Url_Reabertura1 = REA.Vl_Str_Cfg + '?Id_Sessao=' + @Id_Chave
		,Url_Reabertura2 = 'Cd_Chave=' + CAST(USR.Cd_Chave AS VARCHAR(40))
		,Url_Reabertura3 = 'Tp_Gestao=' + CAST(ISNULL(USR.Tp_Gestao, 2) AS VARCHAR(5))
		,Url_Reabertura4 = 'Nr_Cpf_Cgc_Sgd=' + RTRIM(CAST(SMA.Nr_Cpf_Cgc_Sgd AS VARCHAR(20)))
		,Url_Reabertura5 = 'Cd_Corporativo=' + SMA.Cd_Chassi_Seg + '|' + CONVERT(VARCHAR(19), SMA.Dt_Inicio_Vigencia, 120) + '|' + SMA.Nr_Endosso + '|' + CONVERT(VARCHAR(19), SMA.Dt_Hr_Sinistro, 120) + '|' + CAST(SMA.Nr_Seq_Pasta AS VARCHAR(10)) + '|' + ISNULL(SMA.Cd_Chassi_Orc, '') + '|' + ISNULL(CAST(SMA.Nr_Orc AS VARCHAR(10)), '')
		,Nt_Fiscal = CASE 
			WHEN SMA.Id_Situacao_Envio = 5
				AND (
					SELECT Vl_Int_Cfg
					FROM Web_Configuracoes_Seguradora WCS WITH (NOLOCK)
					WHERE WCS.Nr_Cpf_Cgc_Sgd = SMA.Nr_Cpf_Cgc_Sgd
						AND WCS.Cd_Cfg = 71
					) = 1
				THEN 'SIM'
			ELSE 'NAO'
			END
		,Url_Nt_Fiscal = (
			SELECT Vl_Str_Cfg
			FROM Web_Configuracoes_Seguradora WCS WITH (NOLOCK)
			WHERE WCS.Nr_Cpf_Cgc_Sgd = SMA.Nr_Cpf_Cgc_Sgd
				AND WCS.Cd_Cfg = 47
			)
		,Exibe_Botao_Copiar = (
			SELECT Vl_Str_Cfg
			FROM Web_Configuracoes_Seguradora WCS WITH (NOLOCK)
			WHERE WCS.Nr_Cpf_Cgc_Sgd = SMA.Nr_Cpf_Cgc_Sgd
				AND WCS.Cd_Cfg = 57
			)
		,Exibe_Botao_Fotos_Pasta = (
			SELECT Vl_Str_Cfg
			FROM Web_Configuracoes_Seguradora WCS WITH (NOLOCK)
			WHERE WCS.Nr_Cpf_Cgc_Sgd = SMA.Nr_Cpf_Cgc_Sgd
				AND WCS.Cd_Cfg = 82
			)
		,Func_Vistoria_Improdutiva = (
			SELECT Vl_Str_Cfg
			FROM Web_Configuracoes_Seguradora WCS WITH (NOLOCK)
			WHERE WCS.Nr_Cpf_Cgc_Sgd = SMA.Nr_Cpf_Cgc_Sgd
				AND WCS.Cd_Cfg = 83
			)
		,Obriga_Data_Prevista = (
			SELECT Vl_Str_Cfg
			FROM Web_Configuracoes_Seguradora WCS WITH (NOLOCK)
			WHERE WCS.Nr_Cpf_Cgc_Sgd = SMA.Nr_Cpf_Cgc_Sgd
				AND WCS.Cd_Cfg = 84
			)
		,Id_Libera_Reparos = CASE 
			WHEN SMA.Id_Libera_Reparos = 1
				THEN 'SIM'
			ELSE 'NAO'
			END
		,Id_Liberado_Encerrado = CASE 
			WHEN SMA.Id_Liberacao_Anterior = 1
				THEN 'SIM'
			ELSE 'NAO'
			END
		,Id_Notas_Recebidas = CASE 
			WHEN SMA.Id_Situacao_Envio = 5
				THEN SMA.Id_Notas_Recebidas
			ELSE 1
			END
		,Atraso_Seguradora = (DATEDIFF(hour, ISNULL(Dt_Base_Atraso, GETDATE()), GETDATE()) - ISNULL(Qt_Prazo_Seguradora, 24))
		,Atraso_Reguladora = (DATEDIFF(hour, ISNULL(Dt_Base_Atraso, GETDATE()), GETDATE()) - ISNULL(Qt_Prazo_Reguladora, 24))
		,Nr_Cpf_Cgc_Usr = @Nr_Cpf_Cgc_Usr
		,Nr_Cpf_Cgc_Reg = SMA.Nr_Cpf_Cgc_Reg
		,Nr_Cpf_Cgc_Sgd = SMA.Nr_Cpf_Cgc_Sgd
		,Nm_Reguladora = @Nm_Reguladora
		,SMA.Cd_Complemento
		,Cd_Chave_Reg = (
			SELECT Cd_Chave
			FROM Usuario
			WHERE Nr_Cpf_Cgc_Usr = @Nr_Cpf_Cgc_Sgd
				AND Nr_Cpf_Cgc_Sgd = SMA.Nr_Cpf_Cgc_Sgd
			)
		,Tp_Modulo = (
			SELECT Vl_Int_Cfg
			FROM Web_Configuracoes
			WHERE Cd_Cfg = 2
			)
		,Exibe_Outros_Valores = (
			SELECT Vl_Str_Cfg
			FROM Web_Configuracoes_Seguradora WCS WITH (NOLOCK)
			WHERE WCS.Nr_Cpf_Cgc_Sgd = SMA.Nr_Cpf_Cgc_Sgd
				AND WCS.Cd_Cfg = 105
			)
		,Id_Situacao_SLA = dbo.Orc_Fnc_Obtem_Status_SLA(SMA.Cd_Chassi_Seg, SMA.Dt_Inicio_Vigencia, SMA.Nr_Endosso, SMA.Dt_Hr_Sinistro, SMA.Nr_Seq_Pasta, SMA.Nr_Cpf_Cgc_Sgd)
		,AV.Dt_Inclusao_Registro Data_Solicitacao_Revistoria
		,Marca.Ds_Marca
		,AV.Nr_Cpf_Cgc_Envio Vistoriadora
		,Nome_Vistoriadora = CASE 
			WHEN (
					SELECT Count(*)
					FROM Seguradora
					WHERE Nr_Cpf_Cgc_Sgd = AV.Nr_Cpf_Cgc_Envio
					) > 0
				THEN (
						SELECT Nm_Fantasia
						FROM Seguradora
						WHERE Nr_Cpf_Cgc_Sgd = AV.Nr_Cpf_Cgc_Envio
						)
			ELSE (
					SELECT Nm_Usr
					FROM Usuario
					WHERE Nr_Cpf_Cgc_Usr = AV.Nr_Cpf_Cgc_Envio
						AND Nr_Cpf_Cgc_Sgd = AV.Nr_Cpf_Cgc_Sgd
					)
			END
		,ISNULL(TV.Ds_Tipo_Vistoria, '') TipoVistoria
		,TipoVistoriaTitulo = CASE 
			WHEN TV.Ds_Tipo_Vistoria IS NULL
				THEN ''
			ELSE 'Tipo de Vistoria: '
			END
		,SMA.Cd_CGC_Oficina Oficina
		,OFI.Cd_Cep OficinaCEP
		,ValorBruto = format(OCO.Vl_Total_Sinistro, 'C', 'pt-br')
		,ValorLiquido = format(OCO.Vl_Total_Indenizado, 'C', 'pt-br')
		,ValorEstimativa = format(OCO.Vl_Estimativa, 'C', 'pt-br')
		,ValorPecas = format(OCO.Vl_Pecas, 'C', 'pt-br')
		,ValorFornecimentoPecas = format(OCO.Vl_Pecas, 'C', 'pt-br')
		,PS.Dt_Inclusao_Registro DataAberturaOrcamento
		,DataFinalizacaoOrcamento = (
			SELECT MAX(ISNULL(Dt_Inclusao_Registro, ''))
			FROM Orcamento_Carimbo
			WHERE Cd_Chassi_Orc = OCO.Cd_Chassi_Orc
				AND Nr_Orc = OCO.Nr_Orc
				AND Cd_Carimbo = @Cd_Carimbo_Finaliza_Rev
			)
		,DataEncerramentoOrcamento = (
			SELECT MAX(ISNULL(Dt_Inclusao_Registro, ''))
			FROM Orcamento_Carimbo
			WHERE Cd_Chassi_Orc = OCO.Cd_Chassi_Orc
				AND Nr_Orc = OCO.Nr_Orc
				AND Cd_Carimbo = @Cd_Carimbo_Aprova_Rev
			)
		,ISNULL(AV.Id_Status_Revistoria, 0) Id_Status_Revistoria
		,AprovacaoReprovacao = CASE 
			WHEN SMA.Cd_Carimbo = @Cd_Carimbo_Aprova_Rev
				THEN 'APROVADO'
			WHEN SMA.Cd_Carimbo = @Cd_Carimbo_Reprova_Rev
				THEN 'REPROVADO'
			ELSE 'PENDENTE'
			END
		,AberturaIcone = CASE 
			WHEN SMA.Cd_Perito = @Nr_Cpf_Cgc_Usr
				THEN 'SIM'
			ELSE 'NAO'
			END
		,AberturaRevistoria = CASE 
			WHEN @Tp_Usuario IN (
					'20'
					,'23'
					,'24'
					)
				AND SMA.Id_Situacao_Envio <> '17'
				THEN '0'
			WHEN @Tp_Modulo = '2'
				THEN '0'
			WHEN AV.Nr_Cpf_Cgc_Envio <> SMA.Cd_Perito
				AND ISNULL(AV.Id_Status_Revistoria, 0) <> 3
				THEN '0'
			WHEN AV.Id_Situacao_Envio = 6
				AND Nr_Cpf_Cgc_Envio = SMA.Nr_Cpf_Cgc_Sgd
				THEN '0'
			WHEN @Tp_Usuario = '21'
				AND SMA.Cd_Usr_Registro <> @Nr_Cpf_Cgc_Usr
				THEN '0'
			ELSE '1'
			END
		,Devolver = CASE 
			WHEN AV.Id_Situacao_Envio IN (
					6
					,7
					)
				THEN 'SIM'
			ELSE 'NAO'
			END
		,BotaoFinalizar = CASE 
			WHEN (
					SELECT ISNULL(COUNT(*), 0)
					FROM Orcamento_Carimbo OC
					INNER JOIN Seguradora_Carimbo SC ON SC.Cd_Carimbo = OC.Cd_Carimbo
					WHERE OC.Cd_Chassi_Orc = OCO.Cd_Chassi_Orc
						AND OC.Nr_Orc = OCO.Nr_Orc
						AND Id_Revistoria = 1
					) > 0
				THEN 'SIM'
			ELSE 'NAO'
			END
	FROM Sinistro_Master SMA
	INNER JOIN Agenda_Visitas AV ON AV.Cd_Chassi_Seg = SMA.Cd_Chassi_Seg
		AND AV.Dt_Inicio_Vigencia = SMA.Dt_Inicio_Vigencia
		AND AV.Nr_Endosso = SMA.Nr_Endosso
		AND AV.Dt_Hr_Sinistro = SMA.Dt_Hr_Sinistro
		AND AV.Nr_Seq_Pasta = SMA.Nr_Seq_Pasta
	INNER JOIN Pasta_Sinistro PS ON PS.Cd_Chassi_Seg = SMA.Cd_Chassi_Seg
		AND PS.Dt_Inicio_Vigencia = SMA.Dt_Inicio_Vigencia
		AND PS.Nr_Endosso = SMA.Nr_Endosso
		AND PS.Dt_Hr_Sinistro = SMA.Dt_Hr_Sinistro
		AND PS.Nr_Seq_Pasta = SMA.Nr_Seq_Pasta
	INNER JOIN Marca ON Marca.Cd_Marca = PS.Cd_Marca
	INNER JOIN Seguradora SEG ON SMA.Nr_Cpf_Cgc_Sgd = SEG.Nr_Cpf_Cgc_Sgd
	LEFT JOIN Web_Configuracoes_Seguradora REA WITH (NOLOCK) ON REA.Nr_Cpf_Cgc_Sgd = SMA.Nr_Cpf_Cgc_Sgd
		AND REA.Cd_Cfg = 34
	LEFT JOIN Usuario USR ON USR.Nr_Cpf_Cgc_Usr = @Nr_Cpf_Cgc_Sgd
		AND USR.Nr_Cpf_Cgc_Sgd = SMA.Nr_Cpf_Cgc_Sgd
	INNER JOIN Oficina OFI WITH (NOLOCK) ON OFI.Cd_CGC_Oficina = SMA.Cd_CGC_Oficina
	LEFT JOIN Orcamento ORC ON ORC.Cd_Chassi_Seg = SMA.Cd_Chassi_Seg
		AND ORC.Dt_Inicio_Vigencia = SMA.Dt_Inicio_Vigencia
		AND ORC.Nr_Endosso = SMA.Nr_Endosso
		AND ORC.Dt_Hr_Sinistro = SMA.Dt_Hr_Sinistro
		AND ORC.Nr_Seq_Pasta = SMA.Nr_Seq_Pasta
	LEFT JOIN Orcamento_Complemento OCO ON OCO.Cd_Chassi_Orc = ORC.Cd_Chassi_Orc
		AND OCO.Nr_Orc = ORC.Nr_Orc
		AND OCO.Cd_Complemento = SMA.Cd_Complemento
	LEFT JOIN Tipo_Vistoria TV ON TV.Id_Tipo_Vistoria = PS.Id_Tipo_Vistoria
		AND TV.Nr_Cpf_Cgc_Sgd = PS.Nr_Cpf_Cgc_Sgd
	WHERE SMA.Id_Situacao_Envio IN (
			@Id_Situacao_Envio_0
			,@Id_Situacao_Envio_1
			,@Id_Situacao_Envio_2
			,@Id_Situacao_Envio_3
			,@Id_Situacao_Envio_4
			,@Id_Situacao_Envio_5
			,@Id_Situacao_Envio_6
			)
		AND (
			(
				SMA.Cd_Carimbo IN (
					SELECT CAST(PC3.Vl_Pesquisa_1 AS INT)
					FROM Web_Perfil_Consultas PC3 WITH (NOLOCK)
					WHERE PC3.Nr_Cpf_Cgc_Sgd = @Nr_Cpf_Cgc_Sgd
						AND PC3.Nr_Cpf_Cgc_Local = @Nr_Cpf_Cgc_Local
						AND PC3.Nr_Cpf_Cgc_Usr = @Nr_Cpf_Cgc_Usr
						AND PC3.Tp_Filtro = 3
						AND CAST(PC3.Vl_Pesquisa_1 AS INT) = SMA.Cd_Carimbo
					)
				)
			OR @Id_Todos_Carimbos = 1
			)
		AND SMA.Id_Orcamento IN (
			@Id_Orcamento_0
			,@Id_Orcamento_1
			)
		AND SMA.Id_Libera_Reparos = ISNULL(@Id_Libera_Reparos, SMA.Id_Libera_Reparos)
		AND SMA.Id_Notas_Recebidas = ISNULL(@Id_Notas_Recebidas, SMA.Id_Notas_Recebidas)
		AND (
			(
				AV.Dt_Inclusao_Registro >= @M_DT_INICIO
				AND AV.Dt_Inclusao_Registro <= @M_DT_FIM
				)
			)
		AND SMA.Nr_Seq_Pasta > 200
		AND (
			(
				(@Tp_Modulo = '2')
				AND --AMBIENTE SEGURADORA
				(
					(
						@Tp_Consulta = 'D'
						AND (
							(
								AV.Id_Situacao_Envio IN (1)
								AND Nr_Cpf_Cgc_Envio IS NULL
								)
							OR AV.Id_Situacao_Envio IN (16)
							)
						)
					OR (
						@Tp_Consulta = 'R'
						AND AV.Id_Situacao_Envio IN (
							2
							,6
							,15
							,17
							)
						AND Nr_Cpf_Cgc_Envio IS NOT NULL
						AND ISNULL(SMA.Cd_Carimbo, 0) NOT IN (
							@Cd_Carimbo_Aprova_Rev
							,@Cd_Carimbo_Reprova_Rev
							)
						)
					OR (
						@Tp_Consulta = 'F'
						AND AV.Id_Situacao_Envio IN (
							0
							,8
							,17
							,19
							,20
							)
						AND ISNULL(SMA.Cd_Carimbo, 0) IN (
							@Cd_Carimbo_Aprova_Rev
							,@Cd_Carimbo_Reprova_Rev
							)
						)
					)
				)
			OR (
				(@Tp_Modulo = '5')
				AND --AMBIENTE VISTORIADORA
				(
					(
						@Tp_Consulta = 'D'
						AND (
							AV.Id_Situacao_Envio IN (1)
							AND (Nr_Cpf_Cgc_Envio = @Nr_Cpf_Cgc_Sgd)
							)
						OR (
							AV.Id_Status_Revistoria IN (2)
							AND (AV.Cd_Perito = @Nr_Cpf_Cgc_Sgd)
							)
						) ----O CERTO SERÁ Id_Situacao_Envio=1
					OR (
						@Tp_Consulta = 'R'
						AND AV.Id_Situacao_Envio IN (
							0
							,1
							,6
							,7
							,8
							)
						AND (
							--(AV.Cd_Usr_Registro=@Nr_Cpf_Cgc_Usr)
							--or 
							--(Nr_Cpf_Cgc_Envio=@Nr_Cpf_Cgc_Usr)
							--or
							(
								AV.Id_Situacao_Envio = 6
								AND Nr_Cpf_Cgc_Envio = @Nr_Cpf_Cgc_Usr
								)
							OR (
								@Tp_Usuario IN (
									'21'
									,'23'
									,'24'
									)
								AND AV.Nr_Cpf_Cgc_Sgd = @Nr_Cpf_Cgc_Sgd
								)
							OR (
								@Tp_Usuario IN ('22')
								AND AV.Id_Situacao_Envio = 8
								AND Nr_Cpf_Cgc_Envio = @Nr_Cpf_Cgc_Usr
								)
							)
						AND ISNULL(AV.Id_Comunicacao, '') <> '4'
						)
					OR (
						@Tp_Consulta = 'F'
						AND (
							AV.Id_Situacao_Envio IN (
								5
								,18
								,19
								)
							OR AV.Id_Comunicacao = '4'
							)
						)
					)
				)
			)
		AND UPPER(ISNULL(SMA.Nr_Sinistro, '')) LIKE '%' + @F_Nr_Sinistro + '%'
		AND UPPER(ISNULL(SMA.Nr_Aviso_Sinistro, '')) LIKE '%' + @F_Nr_Aviso + '%'
		AND UPPER(ISNULL(SMA.Nr_Placa, '')) LIKE '%' + @F_Placa + '%'
		AND (
			(
				SMA.Nr_Seq_Pasta = 201
				AND UPPER(ISNULL(SMA.Cd_Chassi_Seg, '')) LIKE '%' + @F_Chassi + '%'
				)
			OR (
				SMA.Nr_Seq_Pasta = 202
				AND UPPER(ISNULL(SMA.Cd_Chassi_Terc, '')) LIKE '%' + @F_Chassi + '%'
				)
			)
		AND (
			(
				LEN(@F_Oficina) > 0
				AND (
					UPPER(ISNULL(SMA.Nm_Oficina, '')) LIKE '%' + @F_Oficina + '%'
					OR UPPER(ISNULL(SMA.Cd_CGC_Oficina, '')) LIKE '%' + @F_Oficina + '%'
					)
				)
			OR (LEN(@F_Oficina) = 0)
			)
		AND UPPER(ISNULL(OFI.Cd_UF, '')) LIKE '%' + @F_UF + '%'
		AND UPPER(ISNULL(OFI.Nm_Cidade, '')) LIKE '%' + @F_Cidade + '%'
		AND (
			(@F_Classe = 0)
			OR (
				@F_Classe = 1
				AND SMA.Nr_Seq_Pasta = 201
				)
			OR (
				@F_Classe = 2
				AND SMA.Nr_Seq_Pasta > 201
				)
			)
		AND UPPER(ISNULL(SMA.Ds_Carimbo, '')) LIKE '%' + UPPER(@F_Carimbo) + '%'
		AND (
			(
				@F_Marca > 0
				AND PS.Cd_Marca = @F_Marca
				)
			OR @F_Marca = 0
			)
		AND (
			(
				@F_Tp_Vistoria > 0
				AND ISNULL(PS.Id_Tipo_Vistoria, 0) = @F_Tp_Vistoria
				)
			OR @F_Tp_Vistoria = 0
			)
		AND (
			(@F_Ponto_Impacto = 0)
			OR (
				@F_Ponto_Impacto = 1
				AND SMA.Id_Ponto_Impacto = 1
				)
			OR (
				@F_Ponto_Impacto = 2
				AND SMA.Id_Ponto_Impacto = 0
				)
			)
		AND (
			(
				@F_Estimativa > 0
				AND ISNULL(OCO.Vl_Estimativa, 0) = @F_Estimativa
				)
			OR @F_Estimativa = 0
			)
		AND (
			(
				@F_Fornecimento > 0
				AND ISNULL(OCO.Vl_Pecas, 0) = @F_Fornecimento
				)
			OR @F_Fornecimento = 0
			)
		AND (
			(@Tp_Situacao = '0')
			OR (
				@Tp_Situacao = '1'
				AND @Tp_Consulta = 'F'
				AND @Tp_Modulo = 2
				AND SMA.Cd_Carimbo = @Cd_Carimbo_Aprova_Rev
				) ----- FINALIZADOS APROVADOS - SEGURADORA
			OR (
				@Tp_Situacao = '2'
				AND @Tp_Consulta = 'F'
				AND @Tp_Modulo = 2
				AND SMA.Cd_Carimbo = @Cd_Carimbo_Reprova_Rev
				) ----- FINALIZADOS REJEITADOS - SEGURADORA
			OR (
				@Tp_Situacao = '1'
				AND @Tp_Consulta = 'F'
				AND @Tp_Modulo = 5
				AND ISNULL(AV.Id_Status_Revistoria, '') <> '3'
				) ----- FINALIZADOS APROVADOS - VISTORIADORA
			OR (
				@Tp_Situacao = '2'
				AND @Tp_Consulta = 'F'
				AND @Tp_Modulo = 5
				AND AV.Id_Status_Revistoria = '3'
				) ----- FINALIZADOS REJEITADOS - VISTORIADORA
			OR (
				@Tp_Situacao = '1'
				AND @Tp_Consulta = 'R'
				AND ISNULL(SMA.Cd_Perito, '') <> ''
				) ----- REVISTORIA ENVIADOS 
			OR (
				@Tp_Situacao = '2'
				AND @Tp_Consulta = 'R'
				AND SMA.Id_Situacao_Envio = 8
				) -- AND SMA.Cd_Carimbo = @Cd_Carimbo_Reprova_Rev)  ----- REVISTORIA SENDO REALIZADOS 
			OR (
				@Tp_Situacao = '3'
				AND @Tp_Consulta = 'R'
				AND SMA.Id_Orcamento = 1
				AND ISNULL(AV.Id_Status_Revistoria, '') <> '4'
				AND SMA.Id_Situacao_Envio <> 8
				) -- AND SMA.Cd_Carimbo = @Cd_Carimbo_Reprova_Rev)  ----- REVISTORIA REALIZADOS 
			)
	ORDER BY Id_Situacao_SLA
END
GO


