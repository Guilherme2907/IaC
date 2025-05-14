module "aws-prod"{
    source = "../../infra"
    instancia = "t3.micro"
    regiao_aws = "sa-east-1"
    chave = "iac-curso2-prod"
    nome_instancia = "IaC Curso2 Prod"
}

output "IP" {
  value = module.aws-prod.IP_publico
}