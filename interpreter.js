const peg = require('pegjs');
const fs = require('fs');

var grammer = fs.readFileSync('grammar.pegjs', 'utf-8');
var parser  = peg.generate(grammer,{
    trace:false
})

var input = fs.readFileSync('input.py', 'utf-8');
// parser.parse(input);
try {
    var result = parser.parse(input);
    console.log(result);    
} catch (error) {
    console.log(buildErrorMessage(error))
}

 function buildErrorMessage(e) {
    return e.location !== undefined
      ? "Line " + e.location.start.line + ", column " + e.location.start.column + ": " + e.message
      : e.message;
  }