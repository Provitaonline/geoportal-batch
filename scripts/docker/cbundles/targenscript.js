'use strict'

const BUCKET = process.env.BUCKET
const fs = require('fs')
const manifest = require('./manifest.json')

let cmdFileStream = fs.createWriteStream('./do-tars.sh')

cmdFileStream.write('#!/bin/bash\n')

console.log('building tar gen script')

cmdFileStream.write('echo "begin do-tars"\n')

let filesList = parseFileLs('./files-list')
let cbundlesList = parseFileLs('./cbundles-list')

// Generate tar commands only if tar is not present or if there are more recent files available
for (const collection of Object.keys(manifest)) {
  if (!cbundlesList[collection] || (cbundlesList[collection] && moreRecentFiles(collection))) {
    genTarCmds(collection)
  }
}

// Garbage collect tars that are not in the manifest
for (const cbundle of Object.keys(cbundlesList)) {
  if (!manifest[cbundle]) {
    cmdFileStream.write('echo "removing unused bundle ' + cbundle + '"\n')
    cmdFileStream.write('aws s3 rm "s3://' + BUCKET + '/cbundles/tarfiles/' + cbundle +'.tar" --only-show-errors\n')
  }
}

cmdFileStream.end('echo "end do-tars"\n')

function parseFileLs(fileName) {
  let list = {}
  let filesLs = fs.readFileSync(fileName, {encoding:'utf8'})
  if (filesLs.length > 0) {
    filesLs = filesLs.trim().split('\n')
    filesLs.forEach(f => {
      let idx = f.indexOf(' files/')
      if (idx === -1) idx = f.indexOf(' cbundles/')
      let entries = f.replace(/\s+/g, ' ').split(' ')
      let path = f.substring(idx+1).replace(/\.tar$/, '')
      list[path.split('/').pop()] = {date: new Date(entries[0] + ' ' + entries[1]), path: path}
    })
  }
  return list
}

function genTarCmds(collection) {
  cmdFileStream.write('echo "getting files for collection ' + collection + '"\n')
  manifest[collection].forEach(c => {
    cmdFileStream.write('aws s3 cp ' + '"s3://' + BUCKET + '/' + filesList[c].path + '" . --only-show-errors\n')
  })
  cmdFileStream.write('tar -cf "' + collection + '.tar" "' + manifest[collection].join('" "') + '"\n')
  cmdFileStream.write('echo "uploading bundle for collection ' + collection + '"\n')
  cmdFileStream.write('aws s3 cp "' + collection + '.tar" "s3://' + BUCKET + '/cbundles/tarfiles/' + collection + '.tar" --acl "public-read" --only-show-errors\n')
  cmdFileStream.write('echo "cleaning up collection ' + collection + '"\n')
  cmdFileStream.write('rm "' + manifest[collection].join('" "') + '"\n')
  cmdFileStream.write('rm "' + collection + '.tar"\n')
}

function moreRecentFiles(collection) {
  return manifest[collection].some(f => filesList[f].date > cbundlesList[collection].date)
}
