output "public_ip" {
  value = "${aws_instance.reddit_app.public_ip}"
}
