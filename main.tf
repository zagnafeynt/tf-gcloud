resource "random_pet" "petik" {
  length = 2
}

resource "google_compute_network" "vpc_network" {
  name                    = "my-custom-mode-network-${random_pet.petik.id}"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  name          = "my-custom-subnet-${random_pet.petik.id}"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.id
}

# Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  name                      = "flask-vm-${random_pet.petik.id}"
  machine_type              = var.machine_type
  allow_stopping_for_update = true
  zone                      = var.zone
  tags                      = ["ssh"]

  boot_disk {
    initialize_params {
      image = var.image
    }
  }
  # Install Flask
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python3-pip rsync; pip install flask"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

resource "google_compute_firewall" "ssh" {
  name = "allow-ssh-${random_pet.petik.id}"


  allow {
    protocol = "tcp"
    ports    = ["22", "5000"]
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}
