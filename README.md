# Terraform

## Components
* Terraform executables
* Terraform files
* Terraform plugins
* Terraform state

  * To keep track of current state; compare and make necessary changes using state

* Variables
    ```
    variable "aws_region" {
        default = "us-east-1"
    }
    ```

* Providers
    ```
    provider "aws" {
        access_key = var.access_key
        region = var.aws_region
    }
    ```

* Data 

  * Pull information about entity in the provider like availability zones, amis, etc
    ```
    data "aws_ami" "alx" {

    }
    ```

* Resource
    ```
    resource "aws_instance" "ex" {

    }
    ```

* Output
    ```
    output "aws_public_ip" {

    }
    ```


