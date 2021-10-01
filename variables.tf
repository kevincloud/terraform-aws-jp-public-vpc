variable "unit_prefix" {
    type = string
}

variable "region" {
    type = string
}

variable "tags" {
    type = map(string)
    default = {}
}

variable "cidr_block" {
    type = string
    default = "10.0.0.0/16"
}

variable "public_subnet" {
    type = map(string)
    default = {
        cidr_block = "10.0.1.0/24"
        az = "a"
    }
}

variable "private_subnets" {
    type = list(map(string))
    default = [
        {
            cidr_block = "10.0.2.0/24"
            az = "b"
        },
        {
            cidr_block = "10.0.3.0/24"
            az = "c"
        }
    ]
}
