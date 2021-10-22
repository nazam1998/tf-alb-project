resource "aws_lb" "web_alb" {
  name               = "Production-ALB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets            = aws_subnet.public_subnets.*.id

  tags = {
    Name = "Web App Load Balancer"
  }

  depends_on = [aws_subnet.public_subnets, aws_security_group.alb_sg]
}

resource "aws_lb_target_group" "alb_front_http" {
  name     = "alb-front-http"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mainvpc.id
  health_check {
                path = "/"
                port = "80"
                protocol = "HTTP"
                healthy_threshold = 5
                unhealthy_threshold = 2
                interval = 5
                timeout = 4
                matcher = "200"
    } 

  tags = {
    Name = "Front HTTP Target Group"
  }

  depends_on = [aws_vpc.mainvpc]
}


resource "aws_lb_target_group_attachment" "tg_alb" {
  target_group_arn = aws_lb_target_group.alb_front_http.arn
  count = length(var.public_subnet_cidr)
  port             = 80
  target_id        = element(aws_instance.PublicEC2.*.id, count.index)
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.web_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_front_http.arn
  }

  tags = {
    Name = "Web ALB Listener"
  }

  depends_on = [aws_lb.web_alb, aws_lb_target_group.alb_front_http]
}