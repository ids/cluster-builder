workflow ContainerSetup {
  Install-WindowsFeature -Name Containers -Restart
  Restart-Computer -Wait
  Install-Module -Name DockerMsftProvider -Repository PSGallery -Force -Confirm:$False
  Install-Package -Name docker -ProviderName DockerMsftProvider -Force -Confirm:$False
  Restart-Computer -Wait
}

ContainerSetup



