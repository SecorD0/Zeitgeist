#!/bin/bash
# Options
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo "$1" | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script installs a Zeitgeist node"
		echo
		echo -e "${C_LGn}Usage${RES}: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h, --help  show the help page"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Zeitgeist/blob/main/multi_tool.sh - script URL"
		echo -e "https://t.me/letskynode — node Community"
		echo
		return 0 2>/dev/null; exit 0
		;;
	*|--)
		break
		;;
	esac
done
# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
# Actions
sudo apt install wget -y &>/dev/null
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
if [ "$type" = "" ]; then
	echo
else
	sudo apt update
	sudo apt upgrade -y 
	sudo apt install wget jq build-essential pkg-config libssl-dev -y
	sudo useradd -M zeitgeist
	sudo usermod zeitgeist -s /sbin/nologin
	sudo mkdir -p /services/zeitgeist/bin
	sudo mkdir -p /services/zeitgeist/battery_station
	cd
	zeitgeist_version=`wget -qO- https://api.github.com/repos/zeitgeistpm/zeitgeist/releases/latest | jq -r ".tag_name"`
	wget -qO /services/zeitgeist/bin/zeitgeist "https://github.com/zeitgeistpm/zeitgeist/releases/download/${zeitgeist_version}/zeitgeist_parachain"
	wget -qO /services/zeitgeist/battery_station/battery-station-relay.json "https://github.com/zeitgeistpm/zeitgeist/releases/download/${zeitgeist_version}/battery-station-relay.json"
	chmod +x /services/zeitgeist/bin/zeitgeist
	sudo chown -R zeitgeist:zeitgeist /services/zeitgeist
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/ports_opening.sh) 30333 9933 9944 30334 9934 9945
	sudo tee <<EOF >/dev/null /etc/systemd/system/zeitgeistd.service
[Unit]
Description=Zeitgeist node
After=network.target
Requires=network.target

[Service]
User=zeitgeist
Group=zeitgeist
Restart=on-failure
RestartSec=3
LimitNOFILE=65535
ExecStart=/services/zeitgeist/bin/zeitgeist \\
    --base-path /services/zeitgeist/battery_station \\
    --bootnodes /ip4/45.33.117.205/tcp/30001/p2p/12D3KooWBMSGsvMa2A7A9PA2CptRFg9UFaWmNgcaXRxr1pE1jbe9  \\
    --chain battery_station \\
    --name "$zeitgeist_moniker" \\
    --parachain-id 2050 \\
    --port 30333 \\
    --rpc-port 9933 \\
    --ws-port 9944 \\
    --rpc-external \\
    --ws-external \\
    --rpc-cors all \\
    --pruning archive \\
    -- \\
    --bootnodes=/ip4/45.33.117.205/tcp/31001/p2p/12D3KooWHgbvdWFwNQiUPbqncwPmGCHKE8gUQLbzbCzaVbkJ1crJ \\
    --bootnodes=/ip4/45.33.117.205/tcp/31002/p2p/12D3KooWE5KxMrfJLWCpaJmAPLWDm9rS612VcZg2JP6AYgxrGuuE \\
    --chain /services/zeitgeist/battery_station/battery-station-relay.json \\
    --port 30334 \\
    --rpc-port 9934 \\
    --ws-port 9945

[Install]
WantedBy=multi-user.target
EOF
	sudo systemctl daemon-reload
	sudo systemctl enable zeitgeistd
	sudo systemctl restart zeitgeistd
	. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/miscellaneous/insert_variable.sh) -n zeitgeist_log -v "sudo journalctl -f -n 100 -u zeitgeistd" -a
fi
printf_n "${C_LGn}Done!${RES}"
