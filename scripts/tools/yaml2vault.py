import sys
import os
import yaml
import hvac


def main():
    """
    Retrieves yaml from standard input and loads parameters/values into Vault
    The values are loaded at concourse/TEAM_NAME/PIPELINE_NAME/foo_param
    Expects the following environment variables;
    - VAULT_ADDR = URL for Vault
    - VAULT_TOKEN = Authentication token for Vault
    - TEAM_NAME = Concourse team name
    - PIPELINE_NAME = Name of the Concourse pipeline
    """
    yaml_input = yaml.load(sys.stdin)

    client = hvac.Client(
        url=os.environ['VAULT_ADDR'],
        token=os.environ['VAULT_TOKEN']
    )

    TEAM_NAME = os.environ['TEAM_NAME']
    PIPELINE_NAME = os.environ['PIPELINE_NAME']

    for key, value in yaml_input.iteritems():
        client.write('concourse/{}/{}/{}'.format(
            TEAM_NAME,
            PIPELINE_NAME,
            key), value=value, lease='720h')


if __name__ == "__main__":
    main()
