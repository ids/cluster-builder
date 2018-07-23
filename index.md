---
title:  cluster-builder
---

<div id="title-flash">Automating the Creation of <span id="title-cluster-type">Kubernetes</span> Clusters in <span id="title-vmware-env">VMware ESXi</span> Environments</div>

---

Using freely available tools and only an annotated Ansible inventory file [cluster-builder](https://github.com/ids/cluster-builder) enables the configuration and deployment of fleets of VMware VMs to ESXi and Fusion hypervisors.

---

##### _A single command... and the cluster is deployed!_

<script src="https://asciinema.org/a/h32J527aKzUHHedqDA6KlQn0F.js" id="asciicast-h32J527aKzUHHedqDA6KlQn0F" async data-autoplay="true" data-size="small" data-speed="10"></script>
<script
  src="https://code.jquery.com/jquery-3.3.1.min.js"
  integrity="sha256-FgpCb/KJQlLNfOu91ta32o/NMZxltwRo8QtmkMRdAu8="
  crossorigin="anonymous"></script>

__cluster-builder__ is a unique toolset that can deploy _the identical cluster VM images used for production_ to local VMware Fusion development workstations for both the _operations_ and _development_ teams alike.  This enables both advanced local stack development, as well as meta orchestration cluster development, accelerating all development workflows on a shared codebase.  Clusters can be deployed and re-deployed locally, _and_ into production, _in minutes!_

__cluster-builder__ follows an [immutable infrastructure](https://www.digitalocean.com/community/tutorials/what-is-immutable-infrastructure) philosophy even at the cluster node level.  Container orchestration clusters are defined in a simple text file and then deployed using a single command.  Always repeatable and documented, this single re-usable toolset can deploy numerous and varied orchestration clusters with a clear separation of configuration and deployment artifacts, while offering a mechanism for managing the various cluster definitions packages.

---
<img style="width: 50px" src="/assets/images/cbLogo-50.png" >
[Try Cluster Builder](https://github.com/ids/cluster-builder)

---

<script>

window.onload = function() {

  function swapClusterType() {
    var cluster = $("#title-cluster-type").text();
    switch(cluster) {
      case "Kubernetes":
        cluster = "Docker Swarm";
        break;
      case "Docker Swarm":
        cluster = "DC/OS";
        break;
      default:
        cluster = "Kubernetes";
    }
    $("#title-cluster-type").fadeOut(function(){
      $("#title-cluster-type").html(cluster);
      $("#title-cluster-type").fadeIn();
    });
  }

  function swapEnv() {
    var cluster = $("#title-vmware-env").text();
    switch(cluster) {
      case "VMware ESXi":
        cluster = "VMware Fusion";
        break;
      default:
        cluster = "VMware ESXi";
    }
    $("#title-vmware-env").fadeOut(function(){
      $("#title-vmware-env").html(cluster);
      $("#title-vmware-env").fadeIn();
    });
  }

  setInterval(swapClusterType,5000);
  setInterval(swapEnv,3500);

  swapClusterType();
  swapEnv();

}

</script>

<style>

#title-flash {
  font-weight: 200;
  font-size: 1.5em;
}

#title-cluster-type,
#title-vmware-env {
  font-weight: bolder;
  color: #333;
}
</style>