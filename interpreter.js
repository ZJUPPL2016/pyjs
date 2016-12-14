const peg = require('pegjs');
const fs = require('fs');

var grammer = fs.readFileSync('grammar.pegjs', 'utf-8');
var parser = peg.generate(grammer);
var result = parser.parse('1+2*4');

console.log(result);    // 9