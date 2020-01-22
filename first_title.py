import yaml
import sys

with open(sys.argv[1]) as indexfile:
    data = yaml.load(indexfile, Loader=yaml.FullLoader)
    for sect in data:
        if sect["section"] == "Version":
            continue


        print("---")
        print("layout: redirect")
        print("redirect_url: %s/%s" % (
            sys.argv[2],
            sect["chapters"][0]["title"].lower().replace(" ", "-")
        ))
        print("---")
        break
