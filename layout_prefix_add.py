import sys
import os

data_file = sys.argv[2]

for root, dirs, files in os.walk(sys.argv[1], topdown = False):
    for name in files:
        if name.endswith(".md"):
            fullpath = os.path.join(root, name)
            with open(fullpath + ".tmp", "w") as tmpfile:
                tmpfile.write(
                    "---\nlayout: docs\ndata_file: %s\nversion: %s\n---\n" % (
                        data_file.replace(".", ""),
                        os.path.basename(sys.argv[1])
                    ))

                with open(fullpath) as mdfile:
                    tmpfile.write(mdfile.read())

            os.rename(fullpath+".tmp", fullpath)
