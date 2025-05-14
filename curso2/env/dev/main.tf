module "aws-dev"{
    source = "../../infra"
    instancia = "t3.micro"
    regiao_aws = "us-west-2"
    chave = "iac-curso2-dev"
    nome_instancia = "IaC Curso2 Dev"
}

output "IP" {
  value = module.aws-dev.IP_publico
}