#!/bin/bash

ROOTDIR=$(pwd)

function fetch_docs()
{
    rm -rf ${ROOTDIR}/${TARGET}
    cd ${ROOTDIR}/tmpdocs
    git clone ${REPO}
    echo "Cloned ${PROJECT}"
    cd ${PROJECT}
    latest_version=
    for v in ${VERSIONS}
    do
        latest_version=$v
        git checkout -b v$v $v
        echo "Checked out ${PROJECT}:${v}"
        mkdir -p ${ROOTDIR}/${TARGET}/
        cp -r doc ${ROOTDIR}/${TARGET}/$v
        echo "Doc files copied to ${ROOTDIR}/${TARGET}/$v"
        datafile=$(echo "${TARGET}-$v" | tr -d '.')
        cp ${ROOTDIR}/_data/sample.yml doc/index.yml
        mv doc/index.yml ${ROOTDIR}/_data/${datafile}.yml
        python3 ${ROOTDIR}/layout_prefix_add.py ${ROOTDIR}/${TARGET}/$v ${datafile}
        echo "Added layout prefix to all *.md files.."

        # Set first topic as redirect
        python3 ${ROOTDIR}/first_title.py ${ROOTDIR}/_data/${datafile}.yml /${TARGET}/${v} > ${ROOTDIR}/${TARGET}/${v}/index.md 
    done

    # Redirect to latest page
    echo "---" > ${ROOTDIR}/${TARGET}/index.md
    echo "layout: redirect" >> ${ROOTDIR}/${TARGET}/index.md
    echo "redirect_url: /${TARGET}/${latest_version}" >> ${ROOTDIR}/${TARGET}/index.md
    echo "---" >> ${ROOTDIR}/${TARGET}/index.md

    # Setup latest redirection
    mkdir ${ROOTDIR}/${TARGET}/latest
    echo "---" > ${ROOTDIR}/${TARGET}/latest/index.md
    echo "layout: redirect" >> ${ROOTDIR}/${TARGET}/latest/index.md
    echo "redirect_url: /${TARGET}/${latest_version}" >> ${ROOTDIR}/${TARGET}/latest/index.md
    echo "---" >> ${ROOTDIR}/${TARGET}/latest/index.md

    cd ${ROOTDIR}/tmpdocs
    rm -rf $PROJECT
}

rm -rf ${ROOTDIR}/tmpdocs
mkdir -p ${ROOTDIR}/tmpdocs

REPO=https://github.com/kadalu/kadalu.git
TARGET=k8s-storage
PROJECT=kadalu
VERSIONS="0.3.0 0.4.0"
fetch_docs

cd ${ROOTDIR}/
rm -rf ${ROOTDIR}/tmpdocs
