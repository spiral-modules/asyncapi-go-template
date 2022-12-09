const {exec} = require('child_process')

/**
 * @param {{[key: string]: any}} generator
 * @return {Promise<void>}
 */
async function run(generator) {
  const targetDir = generator.targetDir

  exec(`gofmt -s -w -d ${targetDir}`, (error, stdout, stderr) => {
    if (error) {
      return console.log(`gofmt error: ${error.message}`)
    }

    if (stderr) {
      return console.log(stderr)
    }

    // console.log(`stdout: ${stdout}`)
  })
}

module.exports = {
  'generate:after': run,
}
