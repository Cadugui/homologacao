USE ORION_ORCAMENTOS
GO

IF OBJECT_ID('dbo.Eml_Spr_Ins_Grava_Email_AberturaSinistro_CINS') IS NULL -- Check if SP Exists 
	EXEC sp_executesql @statement = N'CREATE PROCEDURE dbo.Eml_Spr_Ins_Grava_Email_AberturaSinistro_CINS AS SET NOCOUNT ON' -- Create dummy/empty SP 
GO

-- ==============================================================================
--SISTEMA:		ORION ORÇAMENTO V6
--AUTOR:		CONFITEC
--OBJETO:		Eml_Spr_Ins_Grava_Email_AberturaSinistro_CINS
--VERSÃO:		Versão
--DATA:			28/11/2017
--DESCRIÇÃO:	Responsável por inserir o e-mail na fila de envio
--OBSERVAÇÃO:	Informações Adicionais
--APROVADOR:	Responsável pela Aprovação do Processo
--HOMOLOGADO:	Reponsável pela Homologação
-- ==============================================================================
ALTER PROCEDURE [dbo].[Eml_Spr_Ins_Grava_Email_AberturaSinistro_CINS] @Id_Chave AS VARCHAR(80)
	,@Cd_Referencia AS VARCHAR(1000) = NULL
AS
BEGIN
	SET NOCOUNT ON

	DECLARE @Id_Regra AS INT
	DECLARE @Ds_Emails AS VARCHAR(1000)
	DECLARE @Ds_Emails_Adicionais AS VARCHAR(1000)
	DECLARE @Cd_Chassi_Seg AS CHAR(20)
	DECLARE @Dt_Inicio_Vigencia AS SMALLDATETIME
	DECLARE @Nr_Endosso AS CHAR(18)
	DECLARE @Dt_Hr_Sinistro SMALLDATETIME
	DECLARE @Nr_Seq_Pasta AS TINYINT

	SET @Id_Regra = NULL

	EXEC Orc_Spr_Sel_Web_Sessao @Id_Chave = @Id_Chave
		,@Cd_Chassi_Seg = @Cd_Chassi_Seg OUTPUT
		,@Dt_Inicio_Vigencia = @Dt_Inicio_Vigencia OUTPUT
		,@Nr_Endosso = @Nr_Endosso OUTPUT
		,@Dt_Hr_Sinistro = @Dt_Hr_Sinistro OUTPUT
		,@Nr_Seq_Pasta = @Nr_Seq_Pasta OUTPUT

	SET @Ds_Emails = (
			SELECT TOP (1) CAR.Ds_Email_Carteira
			FROM Apolice_Seguro APO
			INNER JOIN Pasta_Sinistro PSI ON APO.Cd_Chassi_Seg = PSI.Cd_Chassi_Seg
				AND APO.Dt_Inicio_Vigencia = PSI.Dt_Inicio_Vigencia
				AND APO.Nr_Endosso = PSI.Nr_Endosso
			INNER JOIN Carteira_Apolice CAR_APO ON CAR_APO.Nr_Apolice_Seguro = APO.Nr_Apolice_Seguro
			INNER JOIN Carteira CAR ON CAR.Nr_Carteira = CAR_APO.Nr_Carteira
			WHERE PSI.Cd_Chassi_Seg = @Cd_Chassi_Seg
				AND PSI.Dt_Inicio_Vigencia = @Dt_Inicio_Vigencia
				AND PSI.Nr_Endosso = @Nr_Endosso
				AND PSI.Dt_Hr_Sinistro = @Dt_Hr_Sinistro
				AND PSI.Nr_Seq_Pasta = @Nr_Seq_Pasta
			)

	IF @Ds_Emails IS NULL
		OR @Ds_Emails = ''
	BEGIN
		SET @Ds_Emails = (
				SELECT SEG.Ds_Email
				FROM Seguradora SEG
				INNER JOIN Pasta_Sinistro PSI ON SEG.Nr_Cpf_Cgc_Sgd = PSI.Nr_Cpf_Cgc_Sgd
				WHERE PSI.Cd_Chassi_Seg = @Cd_Chassi_Seg
					AND PSI.Dt_Inicio_Vigencia = @Dt_Inicio_Vigencia
					AND PSI.Nr_Endosso = @Nr_Endosso
					AND PSI.Dt_Hr_Sinistro = @Dt_Hr_Sinistro
					AND PSI.Nr_Seq_Pasta = @Nr_Seq_Pasta
				)
	END

	SET @Ds_Emails_Adicionais = (
			SELECT USU.Ds_Email
			FROM Usuario USU
			INNER JOIN Sinistro_Master SM ON USU.Nr_Cpf_Cgc_Sgd = SM.Nr_Cpf_Cgc_Sgd
				AND USU.Nr_Cpf_Cgc_Usr = SM.Cd_Usr_Registro
			WHERE SM.Cd_Chassi_Seg = @Cd_Chassi_Seg
				AND Dt_Inicio_Vigencia = @Dt_Inicio_Vigencia
				AND Nr_Endosso = @Nr_Endosso
				AND Dt_Hr_Sinistro = @Dt_Hr_Sinistro
				AND Nr_Seq_Pasta = @Nr_Seq_Pasta
			)

	EXEC [Eml_Spr_Ins_Eml_Email] @Id_Regra = 4
		,@Cd_Chassi_Seg = @Cd_Chassi_Seg
		,@Dt_Inicio_Vigencia = @Dt_Inicio_Vigencia
		,@Nr_Endosso = @Nr_Endosso
		,@Dt_Hr_Sinistro = @Dt_Hr_Sinistro
		,@Nr_Seq_Pasta = @Nr_Seq_Pasta
		,@Ds_Emails = @Ds_Emails
		,@Ds_Emails_Adicionais = @Ds_Emails_Adicionais
		,@Cd_Referencia = @Cd_Referencia
END
GO


