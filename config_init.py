import json
import sys

from hydra import compose, initialize
from omegaconf import OmegaConf

if __name__ == "__main__":
    # context initialization
    with initialize(version_base=None, config_path=sys.argv[1]):
        cfg = compose(config_name=sys.argv[2], overrides=["+db=mysql", "+db.user=me"])
        container = OmegaConf.to_container(cfg, resolve=True)
        print(json.dumps(container))

    # print('done')
