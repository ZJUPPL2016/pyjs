$(document).ready(function() {
    var grammar = $("#grammar").text();
    var parser  = peg.generate(grammar);
    
    $("#submit").click(function(){
        $("#output").val("");
        var input = $("#input").val();
        try {
            // var result = parser.parse(input);
            // console.log("succeed");
            // output(result);  
            var syntaxTree = parser.parse(input);
            var result = runProgram(syntaxTree);
            console.log("succeed");
            console.log(result);
            output(result);
        } catch (error) {
            console.log("fail");            
            output(buildErrorMessage(error));
        }
    });
})

function buildErrorMessage(e) {
    return e.location !== undefined
      ? "Line " + e.location.start.line + ", column " + e.location.start.column + ": " + e.message
      : e.message;
}

function output(message){
    $("#output").val(message);
}


var BaseTypeEnum = Object.freeze({
    NUMBER: 'NUMBER',
    STRING: 'STRING',
    NAME: 'NAME',
    SYMBOL: 'SYMBOL',
    BOOLEAN: 'BOOLEAN'
});

class AbstractObject {
    constructor(type, data) {
        this.type = type;
        this.data = data;
    }
}

class NumberObject extends AbstractObject {
    constructor(num) {
        super(BaseTypeEnum.NUMBER, num);
    }
}

class StringObject extends AbstractObject {
    constructor(str) {
        super(BaseTypeEnum.STRING, str);
    }
}

class NameObject extends AbstractObject {
    constructor(name) {
        super(BaseTypeEnum.NAME, name);
    }
}

class SymbolObject extends AbstractObject {
    constructor(data) {
        super(BaseTypeEnum.SYMBOL, data);
    }
}

class BooleanObject extends AbstractObject {
    constructor(data) {
        super(BaseTypeEnum.BOOLEAN, data);
    }
}

// var input = fs.readFileSync('input.py', 'utf-8');
var syntexTree;

var symbolTableStack = [{}];
var scopeLevel = 0; // 0 means global

var globalNames = {};

function enterScope() {
    scopeLevel++;
    symbolTableStack[scopeLevel] = {};
}

function exitScope() {
    assert(scopeLevel !== 0);
    symbolTableStack.pop();
    scopeLevel--;
}

function findSymbol(name) {
    var symbol;
    if (globalNames[name] === true) {
        symbol = symbolTableStack[0][name];
    } else {
        var level = scopeLevel;
        while (symbol === undefined && level >= 0) {
            symbol = symbolTableStack[level][name];
            level--;
        }
    }
    return function (data) {
        if (data !== undefined) {
            symbol.data = data;
        } else {
            return symbol;
        }
    };
}

function createSymbol(name) {
    symbolTableStack[scopeLevel][name] = new SymbolObject(undefined);
    return function (data) {
        if (data !== undefined) {
            symbolTableStack[scopeLevel][name].data = data;
        } else {
            return symbolTableStack[scopeLevel][name];
        }
    };
}

function checkType(a, b) {
    return a.type === b.type;
}

function run(stmt) {
    switch (stmt.type) {
        case BaseTypeEnum.NUMBER:
        case BaseTypeEnum.STRING:
            return stmt; //stmt is a basic object
        case BaseTypeEnum.NAME:
            var symbolReadOnly = findSymbol(stmt.data)();
            if (symbolReadOnly !== undefined) {
                return symbolReadOnly;
            } else {
                //error
            }
        case "AssignmentExpression":
            if (stmt.left.type !== BaseTypeEnum.NAME) {
                //error
            }
            var symbolName = stmt.left.data;
            var symbolFunction = findSymbol(symbolName);
            if (symbolFunction() === undefined) {
                if (stmt.operator === '=') {
                    symbolFunction = createSymbol(symbolName);
                } else {
                    //error
                }
            }
            switch (stmt.operator) {
                case '=':
                    console.log(symbolFunction());
                    symbolFunction(run(stmt.right));
                    console.log(symbolFunction());
                    break;
                case '+=':
                case '-=':
                case '*=':
                case '/=':
                case '%=':
                case '&=':
                case '|=':
                case '^=':
                case '<<=':
                case '>>=':
                case '**=':
                case '//=':
                default:
                    break;
            }
            break;
        case "BinaryExpression":
            var leftData = run(stmt.left);
            var rightData = run(stmt.right);
            if(checkType(leftData, rightData) === false){
                //error
            }
            switch (stmt.operator) {
                case '>':
                    return new BooleanObject(leftData.data > rightData.data);
                case '<':
                    return new BooleanObject(leftData.data < rightData.data);
                case '==':
                    return new BooleanObject(leftData.data == rightData.data);
                case '!=':
                    return new BooleanObject(leftData.data != rightData.data);
                case 'or':
                    return new BooleanObject(leftData.data || rightData.data);                    
                case 'and':
                    return new BooleanObject(leftData.data && rightData.data);                
                case 'not':
                // ???
                case '<<':
                    return new BooleanObject(leftData.data << rightData.data);                                    
                case '>>':
                    return new BooleanObject(leftData.data >> rightData.data);                    
                case '+':
                    return new BooleanObject(leftData.data + rightData.data);                                    
                case '-':
                    return new BooleanObject(leftData.data - rightData.data);                                                    
                case '*':
                    return new BooleanObject(leftData.data * rightData.data);                                                    
                case '/':
                    return new BooleanObject(leftData.data / rightData.data);                                                    
                case '%':
                    return new BooleanObject(leftData.data % rightData.data);                                                    
                case '**':
                    return new BooleanObject(leftData.data ** rightData.data);                                                    
                case '//':
                    return new BooleanObject(Math.floor(leftData.data / rightData.data));                                                    
            }
            break;
        case "IfStatement":
        case "WhileStatement":
        case "ForStatement":
        case "FunctionDefine":
    }
}

function runProgram(syntaxTree) {
    for (var i = 0; i < syntaxTree[0].length; i++) {
        run(syntaxTree[0][i]);
    }
}