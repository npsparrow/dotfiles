let
  nikhil = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFugzgJ5Lq5yJS+Lt+5QxxWiKp1ResKflGIDit0FPOov";
  users = [ nikhil ];

  systems = [];
in
{
  "rpi_pass.age".publicKeys = users ++ systems;
  "vcvol.age".publicKeys = users ++ systems;
}
