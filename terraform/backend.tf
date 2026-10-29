terraform{
    backend "s3"{
        bucket = "my-tf-state-bucket-himanshu2oo4-zerotrustproject"
        key = "prod/terraform.tfstate"
        region = "ap-south-1"
        use_lockfile = true
    }
}