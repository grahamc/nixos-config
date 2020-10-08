upstream-amis.auto.tfvars.json:
				nix-instantiate \
								--eval --json --strict \
								'<nixpkgs/nixos/modules/virtualisation/ec2-amis.nix>' \
								| jq '{ nixos_amis: . }' > $@
