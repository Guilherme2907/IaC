module "aws-prod"{
    source = "../../infra"
    instancia = "t3.micro"
    regiao_aws = "sa-east-1"
    chave = "iac-curso2-prod"
    nome_instancia = "IaC Curso2 Prod"
    grupoDeSeguranca = "Producao"
    min_machine = 1
    max_machine = 2
    groupName = "Prod"
    producao = true
}
