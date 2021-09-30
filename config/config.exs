# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

config :sqlite_experiments,
  ecto_repos: [SqliteExperiments.Repo]

config :sqlite_experiments,
  SqliteExperiments.Repo,
  database: "/root/database.#{Mix.env()}.sqlite3"

# Enable the Nerves integration with Mix
Application.start(:nerves_bootstrap)

config :sqlite_experiments, target: Mix.target()

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Set the SOURCE_DATE_EPOCH date for reproducible builds.
# See https://reproducible-builds.org/docs/source-date-epoch/ for more information

config :nerves, source_date_epoch: "1632322838"

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

config :logger, backends: [RingLogger]

if Mix.target() == :host or Mix.target() == :"" do
else
  # Use shoehorn to start the main application. See the shoehorn
  # docs for separating out critical OTP applications such as those
  # involved with firmware updates.

  config :shoehorn,
    init: [:nerves_runtime, :nerves_pack],
    app: Mix.Project.config()[:app]

  # Nerves Runtime can enumerate hardware devices and send notifications via
  # SystemRegistry. This slows down startup and not many programs make use of
  # this feature.

  config :nerves_runtime, :kernel, use_system_registry: false

  # Erlinit can be configured without a rootfs_overlay. See
  # https://github.com/nerves-project/erlinit/ for more information on
  # configuring erlinit.

  config :nerves,
    erlinit: [
      hostname_pattern: "nerves-%s",
      ctty: "ttyAMA0"
    ]

  # Configure the device for SSH IEx prompt access and firmware updates
  #
  # * See https://hexdocs.pm/nerves_ssh/readme.html for general SSH configuration
  # * See https://hexdocs.pm/ssh_subsystem_fwup/readme.html for firmware updates

  keys =
    [
      Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
      Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
      Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
    ]
    |> Enum.filter(&File.exists?/1)

  if keys == [],
    do:
      Mix.raise("""
      No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
      log into the Nerves device and update firmware on it using ssh.
      See your project's config.exs for this error message.
      """)

  config :nerves_ssh,
    authorized_keys: Enum.map(keys, &File.read!/1)

  # Configure the network using vintage_net
  # See https://github.com/nerves-networking/vintage_net for more information
  config :vintage_net,
    regulatory_domain: "US",
    config: [
      {"usb0", %{type: VintageNetDirect}},
      {"eth0",
       %{
         type: VintageNetEthernet,
         ipv4: %{method: :dhcp}
       }},
      {"wlan0", %{type: VintageNetWiFi}}
    ]

  config :mdns_lite,
    # The `host` key specifies what hostnames mdns_lite advertises.  `:hostname`
    # advertises the device's hostname.local. For the official Nerves systems, this
    # is "nerves-<4 digit serial#>.local".  mdns_lite also advertises
    # "nerves.local" for convenience. If more than one Nerves device is on the
    # network, delete "nerves" from the list.

    host: [:hostname, "nerves"],
    ttl: 120,

    # Advertise the following services over mDNS.
    services: [
      %{
        protocol: "ssh",
        transport: "tcp",
        port: 22
      },
      %{
        protocol: "sftp-ssh",
        transport: "tcp",
        port: 22
      },
      %{
        protocol: "epmd",
        transport: "tcp",
        port: 4369
      }
    ]

  # Import target specific config. This must remain at the bottom
  # of this file so it overrides the configuration defined above.
  # Uncomment to use target specific configurations

  # import_config "#{Mix.target()}.exs"
end
