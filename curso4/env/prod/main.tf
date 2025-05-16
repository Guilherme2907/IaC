module "Producao" {
  source = "../../infra"
  nome = "producao"
  descricao = "aplicacao-de-producao"
  max = 3
  maquina = "t3.micro"
  ambiente = "ambiente-de-producao"
}