# variables.tf

variable "resource_group_name" {
  type        = string
  description = "Name of the resource group"
}

variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region"
}

variable "admin_username" {
  type        = string
  description = "Admin username for the VM"
}

variable "public_key_path" {
  type        = string
  description = "Path to your SSH public key"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}

variable "my_public_ip" {
  type        = string
  description = "Your public IP address"
}

variable "domain_name_label" {
  type        = string
  description = "The domain name label for the public IP"
}

variable "storage_account_name" {
  type        = string
  description = "The name of the storage account"
}

variable "storage_container_name" {
  type        = string
  description = "The name of the storage container"
}

variable "alert_email_address" {
  type        = string
  description = "Email address to receive alerts"
}