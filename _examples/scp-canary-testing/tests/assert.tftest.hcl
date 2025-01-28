run "sg_assert_allow_region" {
  command = plan
  
  // this region is allowed via scp
  variables {
    region = "eu-north-1"
  }

  variables {
    assumable_role_arn = "arn:aws:iam::xxxxxxxxxxxxxx:role/role-name"
  }
  
  module {
    source = "./tests/setup/read_security_groups"
  }
}

run "sg_assert_deny_region" {
  command = plan
  
  // this region is denied via scp
  variables {
    region = "eu-west-1"
  }

  variables {
    assumable_role_arn = "arn:aws:iam::xxxxxxxxxxxxxx:role/role-name"
  }
  
  module {
    source = "./tests/setup/read_security_groups"
  }
}