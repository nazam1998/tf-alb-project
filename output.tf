
output "vpc_id" {
  value = aws_vpc.mainvpc.id
}

output "alb_dns" {
  value = aws_lb.web_alb.dns_name
}
