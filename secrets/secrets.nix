let
  nikhil = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFugzgJ5Lq5yJS+Lt+5QxxWiKp1ResKflGIDit0FPOov";
  users = [ nikhil ];

  sparrow = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMOTFCglBlDqZ6MhR642dpE/6pbNZaTkRQpWOH+OJzP";
  systems = [ sparrow ];
in
{
  "rpi_pass.age".publicKeys = users ++ systems;
  "vcvol.age".publicKeys = users ++ systems;
}
