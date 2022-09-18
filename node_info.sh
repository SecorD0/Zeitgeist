#!/bin/bash
# Default variables
language="EN"
raw_output="false"

# Options
. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/colors.sh) --
option_value(){ echo $1 | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)
		. <(wget -qO- https://raw.githubusercontent.com/SecorD0/utils/main/logo.sh)
		echo
		echo -e "${C_LGn}Functionality${RES}: the script shows information about a Zeitgeist node"
		echo
		echo -e "Usage: script ${C_LGn}[OPTIONS]${RES}"
		echo
		echo -e "${C_LGn}Options${RES}:"
		echo -e "  -h, --help               show help page"
		echo -e "  -l, --language LANGUAGE  use the LANGUAGE for texts"
		echo -e "                           LANGUAGE is '${C_LGn}EN${RES}' (default), '${C_LGn}RU${RES}'"
		echo -e "  -ro, --raw-output        the raw JSON output"
		echo
		echo -e "You can use either \"=\" or \" \" as an option and value ${C_LGn}delimiter${RES}"
		echo
		echo -e "${C_LGn}Useful URLs${RES}:"
		echo -e "https://github.com/SecorD0/Zeitgeist/blob/main/node_info.sh - script URL"
		echo -e "         (you can send Pull request with new texts to add a language)"
		echo -e "https://t.me/OnePackage — noderun and tech community"
		echo -e "https://learning.1package.io — guides and articles"
		echo -e "https://teletype.in/@letskynode — guides and articles"
		echo
		return 0 2>/dev/null; exit 0
		;;
	-l*|--language*)
		if ! grep -q "=" <<< $1; then shift; fi
		language=`option_value $1`
		shift
		;;
	-ro|--raw-output)
		raw_output="true"
		shift
		;;
	*|--)
		break
		;;
	esac
done

# Config
using_docker="true"
software_name="zeitgeist_node"

# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
api_request() { wget -qO- -t 1 -T 5 --header "Content-Type: application/json" --post-data '{"id":1, "jsonrpc":"2.0", "method": "'$1'"}' "http://localhost:$2/" | jq; }
main() {
	# Texts
	if [ "$language" = "RU" ]; then
		local t_nn="\nНазвание ноды:               ${C_LGn}%s${RES}"
		local t_nv="Версия ноды:                 ${C_LGn}%s${RES}"
		
		local t_net_1="\nСеть:                        ${C_LGn}%s${RES}"
		local t_ni_1=" ID ноды:                    ${C_LGn}%s${RES}"
		local t_lb_1=" Последний блок:             ${C_LGn}%d${RES}"
		local t_sy1_1=" Нода синхронизирована:      ${C_LR}нет${RES}"
		local t_sy2_1=" Осталось нагнать:           ${C_LR}%d-%d=%d (около %.2f мин.)${RES}"
		local t_sy3_1=" Нода синхронизирована:      ${C_LGn}да${RES}"
		
		local t_net_2="\n\nСеть:                        ${C_LGn}%s${RES}"
		local t_ni_2=" ID ноды:                    ${C_LGn}%s${RES}"
		local t_lb_2=" Последний блок:             ${C_LGn}%d${RES}"
		local t_sy1_2=" Нода синхронизирована:      ${C_LR}нет${RES}"
		local t_sy2_2=" Осталось нагнать:           ${C_LR}%d-%d=%d (около %.2f мин.)${RES}"
		local t_sy3_2=" Нода синхронизирована:      ${C_LGn}да${RES}"
		
	# Send Pull request with new texts to add a language - https://github.com/SecorD0/Zeitgeist/blob/main/node_info.sh
	#elif [ "$language" = ".." ]; then
	else
		local t_nn="\nMoniker:                  ${C_LGn}%s${RES}"
		local t_nv="Node version:             ${C_LGn}%s${RES}"
		
		local t_net_1="\nNetwork:                  ${C_LGn}%s${RES}"
		local t_ni_1=" Node ID:                 ${C_LGn}%s${RES}"
		local t_lb_1=" Latest block height:     ${C_LGn}%s${RES}"
		local t_sy1_1=" Node is synchronized:    ${C_LR}no${RES}"
		local t_sy2_1=" It remains to catch up:  ${C_LR}%d-%d=%d (about %.2f min.)${RES}"
		local t_sy3_1=" Node is synchronized:    ${C_LGn}yes${RES}"
		
		local t_net_2="\n\nNetwork:                  ${C_LGn}%s${RES}"
		local t_ni_2=" Node ID:                 ${C_LGn}%s${RES}"
		local t_lb_2=" Latest block height:     ${C_LGn}%s${RES}"
		local t_sy1_2=" Node is synchronized:    ${C_LR}no${RES}"
		local t_sy2_2=" It remains to catch up:  ${C_LR}%d-%d=%d (about %.2f min.)${RES}"
		local t_sy3_2=" Node is synchronized:    ${C_LGn}yes${RES}"
	fi

	# Actions
	sudo apt install jq bc -y &>/dev/null
	if [ "$using_docker" = "true" ]; then
		local moniker=`docker logs "$software_name" | grep Node | tail -1 | awk '{ printf $(NF-1) }'`
	else
		local moniker=`sudo journalctl -fn 100 -u "$software_name" | grep Node | tail -1 | awk '{ printf $(NF-1) }'`
	fi
	local node_version=`api_request system_version 9933 | jq -r ".result"`
	
	local network_1=`api_request system_chain 9933 | jq -r ".result"`
	local node_id_1=`api_request system_localPeerId 9933 | jq -r ".result"`
	local latest_block_height_1=`api_request system_syncState 9933 | jq -r ".result.currentBlock"`
	local catching_up_1=`api_request system_health 9933 | jq -r ".result.isSyncing"`
	
	local network_2=`api_request system_chain 9934 | jq -r ".result"`
	local node_id_2=`api_request system_localPeerId 9934 | jq -r ".result"`
	local latest_block_height_2=`api_request system_syncState 9934 | jq -r ".result.currentBlock"`
	local catching_up_2=`api_request system_health 9934 | jq -r ".result.isSyncing"`
	
	# Output
	if [ "$raw_output" = "true" ]; then
		printf_n '[{"moniker": "%s", "node_version": "%s", "networks": [{"network": "%s", "node_id": "%s", "latest_block_height": %d, "catching_up": %b}, {"network": "%s", "node_id": "%s", "latest_block_height": %d, "catching_up": %b}]}]' \
"$moniker" \
"$node_version" \
"$network_1" \
"$node_id_1" \
"$latest_block_height_1" \
"$catching_up_1" \
"$network_2" \
"$node_id_2" \
"$latest_block_height_2" \
"$catching_up_2"
	else
		printf_n "$t_nn" "$moniker"
		printf_n "$t_nv" "$node_version"
		
		printf_n "$t_net_1" "$network_1"
		printf_n "$t_ni_1" "$node_id_1"
		printf_n "$t_lb_1" "$latest_block_height_1"
		if [ "$catching_up_1" = "true" ]; then
			local current_block_1=`api_request system_syncState 9933 | jq ".result.highestBlock"`
			local diff_1=`bc -l <<< "$current_block_1-$latest_block_height_1"`
			local takes_time_1=`bc -l <<< "$diff_1/60/60"`
			printf_n "$t_sy1_1"
			printf_n "$t_sy2_1" "$current_block_1" "$latest_block_height_1" "$diff_1" "$takes_time_1"		
		else
			printf_n "$t_sy3_1"
		fi
		
		printf_n "$t_net_2" "$network_2"
		printf_n "$t_ni_2" "$node_id_2"
		printf_n "$t_lb_2" "$latest_block_height_2"
		if [ "$catching_up_2" = "true" ]; then
			local current_block_2=`api_request system_syncState 9934 | jq ".result.highestBlock"`
			local diff_2=`bc -l <<< "$current_block_2-$latest_block_height_2"`
			local takes_time_2=`bc -l <<< "$diff_2/350/60"`
			printf_n "$t_sy1_2"
			printf_n "$t_sy2_2" "$current_block_2" "$latest_block_height_2" "$diff_2" "$takes_time_2"		
		else
			printf_n "$t_sy3_2"
		fi
		printf_n
	fi
}

main
