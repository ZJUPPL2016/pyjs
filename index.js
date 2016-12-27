var syntexTree;

var symbolTableStack = [{}];
var scopeLevel = 0; // 0 means global

var globalNames = {};

$(document).ready(function () {
    var grammar = $("#grammar").text();
    var parser = peg.generate(grammar);

    $("#submit").click(function () {
        $("#output").val("");

        symbolTableStack = [{}];
        scopeLevel = 0; // 0 means global

        globalNames = {};

        var input = $("#input").val();
        try {
            // var result = parser.parse(input);
            // console.log("succeed");
            // output(result);  
            var syntaxTree = parser.parse(input);
            try {
                runProgram(syntaxTree);
            } catch (e) {
                output(e.message);
            }
            output("\nSyntax Tree:\n" + JSON.stringify(syntaxTree, null, 4));
            console.log("succeed");
        } catch (error) {
            console.log("fail");
            output(buildErrorMessage(error));
        }
    });
})

function buildErrorMessage(e) {
    return e.location !== undefined ?
        "Line " + e.location.start.line + ", column " + e.location.start.column + ": " + e.message :
        e.message;
}

function output(message) {
    $("#output").val($("#output").val() + "\n" + message);
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
class RunTimeException {
    constructor(message) {
        this.message = message;
    }
}

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

function checkType(a, b, validList) {
    if (a.type !== b.type) {
        throw new RunTimeException("Unsupported operand(s) type");
    } else if (validList !== undefined && validList.indexOf(a.type) === -1) {
        throw new RunTimeException("Unsupported operand(s) type");
    }
}

function run(stmt) {
    if (stmt.constructor === Array) {
        var result;
        for (var i = 0; i < stmt.length; i++) {
            try {
                result = run(stmt[i]);
            } catch (e) {
                throw e;
            }
        }
        return result;
    }
    switch (stmt.type) {
        case BaseTypeEnum.NUMBER:
        case BaseTypeEnum.STRING:
        case BaseTypeEnum.BOOLEAN:
            return stmt; //stmt is a basic object
        case BaseTypeEnum.NAME:
            var symbolReadOnly = findSymbol(stmt.data)();
            if (symbolReadOnly !== undefined) {
                return symbolReadOnly.data;
            } else {
                throw new RunTimeException("Name \'" + stmt.data + "\' is not defined");
            }
        case "AssignmentExpression":
            if (stmt.left.type !== BaseTypeEnum.NAME) {
                throw new RunTimeException("Can't assign to literal");
            }
            var symbolName = stmt.left.data;
            var symbolFunction = findSymbol(symbolName);
            if (symbolFunction() === undefined) {
                if (stmt.operator === '=') {
                    symbolFunction = createSymbol(symbolName);
                } else {
                    throw new RunTimeException("Name \'" + stmt.data + "\' is not defined");
                }
            }
            var rightData;
            try {
                rightData = run(stmt.right);
            } catch (e) {
                throw e;
            }
            if (stmt.operator !== '=') {
                try {
                    checkType(symbolFunction().data, rightData);
                } catch (e) {
                    throw e;
                }
            }
            switch (stmt.operator) {
                case '=':
                    symbolFunction(rightData);
                    console.log(symbolFunction());
                    break;
                case '+=':
                    symbolFunction(new AbstractObject(rightData.type, symbolFunction().data.data + rightData.data));
                    console.log(symbolFunction());
                    break;
                case '-=':
                    symbolFunction(new AbstractObject(rightData.type, symbolFunction().data.data - rightData.data));
                    console.log(symbolFunction());
                    break;
                case '*=':
                    symbolFunction(new AbstractObject(rightData.type, symbolFunction().data.data * rightData.data));
                    console.log(symbolFunction());
                    break;
                case '/=':
                    symbolFunction(new AbstractObject(rightData.type, symbolFunction().data.data / rightData.data));
                    console.log(symbolFunction());
                    break;
                case '%=':
                    symbolFunction(new AbstractObject(rightData.type, symbolFunction().data.data % rightData.data));
                    console.log(symbolFunction());
                    break;
                case '&=':
                    symbolFunction(new AbstractObject(rightData.type, symbolFunction().data.data & rightData.data));
                    console.log(symbolFunction());
                    break;
                case '|=':
                    symbolFunction(new AbstractObject(rightData.type, symbolFunction().data.data | rightData.data));
                    console.log(symbolFunction());
                    break;
                case '^=':
                    symbolFunction(new AbstractObject(rightData.type, symbolFunction().data.data ^ rightData.data));
                    console.log(symbolFunction());
                    break;
                case '<<=':
                    symbolFunction(new AbstractObject(rightData.type, symbolFunction().data.data << rightData.data));
                    console.log(symbolFunction());
                    break;
                case '>>=':
                    symbolFunction(new AbstractObject(rightData.type, symbolFunction().data.data >> rightData.data));
                    console.log(symbolFunction());
                    break;
                case '**=':
                    symbolFunction(new AbstractObject(rightData.type, symbolFunction().data.data ** rightData.data));
                    console.log(symbolFunction());
                    break;
                case '//=':
                    symbolFunction(new AbstractObject(rightData.type, Math.floor(symbolFunction().data.data / rightData.data)));
                    console.log(symbolFunction());
                    break;
                default:
                    break;
            }
            break;
        case "BinaryExpression":
            var leftData;
            var rightData;
            try {
                leftData = run(stmt.left);
                rightData = run(stmt.right);
                checkType(leftData, rightData);
            } catch (e) {
                throw e;
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
                    return new NumberObject(leftData.data << rightData.data);
                case '>>':
                    return new NumberObject(leftData.data >> rightData.data);
                case '+':
                    return new AbstractObject(leftData.type, leftData.data + rightData.data);
                case '-':
                    return new AbstractObject(leftData.type, leftData.data - rightData.data);
                case '*':
                    return new NumberObject(leftData.data * rightData.data);
                case '/':
                    return new NumberObject(leftData.data / rightData.data);
                case '%':
                    return new NumberObject(leftData.data % rightData.data);
                case '**':
                    return new NumberObject(leftData.data ** rightData.data);
                case '//':
                    return new NumberObject(Math.floor(leftData.data / rightData.data));
            }
            break;
        case "IfStatement":
            try {
                if (run(stmt.test).data === true) {
                    return run(stmt.consequent);
                } else if (stmt.eliftest.length !== 0) {
                    for (var i = 0; i < stmt.eliftest.length; i++) {
                        if (run(stmt.eliftest[i]).data === true) {
                            return run(stmt.elifalternative[i]);
                        }
                    }
                }
                if (stmt.alternative != null && stmt.alternative.length !== 0) {
                    return run(stmt.alternative);
                }
            } catch (e) {
                throw e;
            }
            break;
        case "WhileStatement":
            try {
                while (run(stmt.test).data === true) {
                    run(stmt.body);
                }
            } catch (e) {
                throw e;
            }
            break;
        case "ForStatement":
        case "FunctionDefinition":
        case "Global":
        case "AtomWithTrailer":
            if (stmt.name.data === "print") {
                if (stmt.trailer[0].type === "CallFunction" && stmt.trailer[0].arglist) {
                    for (var i = 0; i < stmt.trailer[0].arglist.length; i++) {
                        try {
                            result = run(stmt.trailer[0].arglist[i][0]);
                            output(result.data);
                        } catch (e) {
                            throw e;
                        }
                    }
                }
            }
            break;
    }
}

function runProgram(syntaxTree) {
    for (var i = 0; i < syntaxTree[0].length; i++) {
        try {
            run(syntaxTree[0][i]);
        } catch (e) {
            throw e;
        }
    }
}