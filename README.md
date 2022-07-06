# lucidity-task
1. Create an EC2 instance that has a microservice running on it.  
2. Create other EC2 instances which have Prometheus and Grafana running on them
3. Scrape metrics from the EC2 instance running the microservice in Prometheus

Note:
1. Fill variables.tf with actual values
2. Creating and defining network space,ssh key gen is omitted 
3. Terraform version used is Terraform v1.2.4 on windows_amd64
4. Code is validated using terraform validate only, Apply cant be done becasue of AWS account issues

