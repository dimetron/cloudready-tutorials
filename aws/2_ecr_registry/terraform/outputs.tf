output "repository_url" {
  value = "${aws_ecr_repository.ecr.repository_url}"
}
output "repository_url_cli" {
  value = "${aws_ecr_repository.ecr1.repository_url}"
}
output "repository_url_img" {
  value = "${aws_ecr_repository.ecr2.repository_url}"
}