/** Main application file
 * Kicks off the whole show
 */
var   express = require('express')
    , fs = require('fs')
    , app = express()
    , port = process.env.PORT || 8080


console.log("\n\nStarting in mode:", app.settings.env);

app.config = process.env;

// Configuration
require('./lib/settings').boot(app);


//Error Handler
require('./lib/error-handler').boot(app);


// Start the app by listening on <port>
var server = app.listen(port);

// Bootstrap controllers
controller_loc = __dirname + '/controllers';
controller_files = fs.readdirSync(controller_loc);
controller_files.forEach( function (file) {
  require(controller_loc + '/' + file)(app);
})

console.log('JobShark started on port ' + port);

