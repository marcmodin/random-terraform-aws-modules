# Demo on how to smoke-test service control policies

1. run terraform init, plan and apply as your usual workflow
2. terraform in test/setup/ use assume role to run tests in a canary account
3. run `terraform test` triggers terraform plan and report failure or success (thats it!)
