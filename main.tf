terraform {
  required_providers {
    google = {
      source = "hashicorp/google"
      version = "5.30.0"
    }
  }
}

provider "google" {
  # Configuration options
  region = "us-east1"
    zone   = "us-east1-b"
    credentials = "mentis-negotium-17998feda7af.json"
    project = "mentis-negotium"
}

resource "google_compute_network" "T1-amrageddon-vpc" {
  project                 = "mentis-negotium"
  name                    = "t1amrageddon-vpc"
  auto_create_subnetworks = true
}

resource "google_compute_firewall" "T1-amrageddon-allow-ssh" {
  project     = "mentis-negotium"
  name        = "t1firewall"
  network     = google_compute_network.T1-amrageddon-vpc.self_link
   allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["443", "80"]
  }

  source_tags = ["https", "http"]
}

     
  


# resource "google_service_account" "default" {
#   account_id   = "my-custom-sa"
#   display_name = "Custom SA for VM Instance"
# }

resource "google_compute_instance" "T1_amrageddon_vm" {
  name         = "t1-amrageddon-vm"
  machine_type = "n2-standard-2"
  zone         = "us-east1-b"
  

  tags = ["https", "http"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      labels = {
        my_label = "value"
      }
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "NVME"
  }

  network_interface {
        network = google_compute_network.T1-amrageddon-vpc.self_link

    access_config {
      // Ephemeral public IP
    }
  }



  metadata = {
    startup-script = file("runscript.sh")
  }

}