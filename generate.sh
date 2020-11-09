#!/bin/bash

SCRIPTDIR=$(pwd)
cd src
ROOTDIR=$(pwd)


function fetch_docs()
{
    rm -rf ${ROOTDIR}/${TARGET}
    cd ${ROOTDIR}/tmpdocs
    git clone ${REPO}
    echo "Cloned ${PROJECT}"
    cd ${PROJECT}
    latest_version=
    datafile=
    echo "versions:" > ${ROOTDIR}/_data/${TARGET}-versions.yml
    for v in ${VERSIONS}
    do
        echo "  - ${v}" >> ${ROOTDIR}/_data/${TARGET}-versions.yml        
        latest_version=$v
        git checkout -b v$v $v
        echo "Checked out ${PROJECT}:${v}"
        mkdir -p ${ROOTDIR}/${TARGET}/

	# Make sure to convert the local links in github to proper links in website
	sed -i -e "s#](./\(.*\)[\.][m][d])#](https://kadalu.io/docs/${TARGET}/${v}/\1)#g" doc/*.md

	# Make sure to convert the local links in github to proper links in github itself
	sed -i -e "s#](../#](https://github.com/kadalu/${PROJECT}/tree/${v}/#g" doc/*.md

        cp -r doc ${ROOTDIR}/${TARGET}/$v
        echo "Doc files copied to ${ROOTDIR}/${TARGET}/$v"
        datafile=$(echo "${TARGET}-$v" | tr -d '.')
        mv doc/index.yml ${ROOTDIR}/_data/${datafile}.yml
        python3 ${SCRIPTDIR}/layout_prefix_add.py ${ROOTDIR}/${TARGET}/$v ${datafile}
        echo "Added layout prefix to all *.md files.."

        # Set first topic as redirect
        python3 ${SCRIPTDIR}/first_title.py ${ROOTDIR}/_data/${datafile}.yml /${URLPREFIX}/${TARGET}/${v} > ${ROOTDIR}/${TARGET}/${v}/index.md 
    done

    # Redirect to latest page
    echo "---" > ${ROOTDIR}/${TARGET}/index.md
    echo "layout: redirect" >> ${ROOTDIR}/${TARGET}/index.md
    echo "redirect_url: /${URLPREFIX}/${TARGET}/latest" >> ${ROOTDIR}/${TARGET}/index.md
    echo "---" >> ${ROOTDIR}/${TARGET}/index.md

    cp -r ${ROOTDIR}/${TARGET}/${latest_version} ${ROOTDIR}/${TARGET}/latest
    cp -r ${ROOTDIR}/_data/$datafile ${ROOTDIR}/_data/${TARGET}-latest.yml

    # Make sure to change the latest_version to 'latest' in links too.
    sed -i -e "s#](https://kadalu.io/docs/${TARGET}/${latest_version}/#](https://kadalu.io/docs/${TARGET}/latest/#g" ${ROOTDIR}/${TARGET}/latest/*

    python3 ${SCRIPTDIR}/first_title.py ${ROOTDIR}/_data/${datafile}.yml /${URLPREFIX}/${TARGET}/latest > ${ROOTDIR}/${TARGET}/latest/index.md 

    cd ${ROOTDIR}/tmpdocs
    rm -rf $PROJECT
}

rm -rf ${ROOTDIR}/tmpdocs
mkdir -p ${ROOTDIR}/tmpdocs
mkdir -p ${ROOTDIR}/_data

URLPREFIX=docs
REPO=https://github.com/kadalu/kadalu.git
TARGET=k8s-storage
PROJECT=kadalu
VERSIONS="devel"
fetch_docs

cd ${ROOTDIR}/
rm -rf ${ROOTDIR}/tmpdocs
