{
  function debug(text, location){
    console.log(text);
  }
  var indentStack = [], indent = "";

  var BaseTypeEnum = Object.freeze({
    NUMBER: 'NUMBER',
    STRING: 'STRING',
    NAME: 'NAME'
  })

  // class AbstractObject {
  //   constructor(type, data) {
  //     this.type = type;
  //     this.data = data;
  //   }
  // }

  // class NumberObject {
  //   constructor(num) {
  //     super(BaseTypeEnum.NUMBER, num);
  //   }
  // }

  // class StringObject {
  //   constructor(str) {
  //     super(BaseTypeEnum.STRING, str);
  //   }
  // }

  function checkType(a, b) {
    return a.type === b.type;
  }
}

/*single_input= NEWLINE / simple_stmt / compound_stmt NEWLINE*/ 
file_input= (NEWLINE / stmt)* ENDMARKER 
/*eval_input= testlist NEWLINE* ENDMARKER */

decorator= '@' dotted_name ( '('_ (arglist)? _')' )? NEWLINE
decorators= decorator+
decorated= decorators (classdef / funcdef / async_funcdef)

async_funcdef= ASYNC _ funcdef
funcdef='def' _ NAME parameters ('->'_ test)? _ ':' _ suite 

parameters= '('_ (typedargslist)? _')'
typedargslist= (tfpdef ('=' test)? (','  tfpdef ('=' test)?)* (','
       ('*' (tfpdef)? (',' tfpdef ('=' test)?)* (',' '**' tfpdef)? / '**' tfpdef)?)?
     /  '*' (tfpdef)? (',' tfpdef ('=' test)?)* (',' '**' tfpdef)? / '**' tfpdef)
tfpdef=NAME (':' test)?
varargslist= (vfpdef ('=' test)? (',' vfpdef ('=' test)?)* (','
       ('*' (vfpdef)? (',' vfpdef ('=' test)?)* (',' '**' vfpdef)? / '**' vfpdef)?)?
     /  '*' (vfpdef)? (',' vfpdef ('=' test)?)* (',' '**' vfpdef)? / '**' vfpdef)
vfpdef= NAME

stmt= simple_stmt {debug(text(),location()); return text();}
    / compound_stmt {debug(text(),location()); return text();}
simple_stmt= small_stmt (';' small_stmt)* (';')? NEWLINE
small_stmt= (expr_stmt / del_stmt / pass_stmt /flow_stmt /
             import_stmt / global_stmt / nonlocal_stmt / assert_stmt)
expr_stmt= testlist_star_expr ( ( _ augassign _ (yield_expr/testlist)) /
                     (_ '=' _ (yield_expr/testlist_star_expr))*)
testlist_star_expr= (test/star_expr) (',' (test/star_expr))* (',')?
augassign=('+=' / '-=' / '*=' / '@=' / '/='/ '%=' / '&=' / '|=' / '^=' /
            '<<=' / '>>=' / '**=' / '//=')
            
            
del_stmt='del' exprlist
pass_stmt= 'pass'
flow_stmt= break_stmt / continue_stmt / return_stmt / raise_stmt / yield_stmt
break_stmt='break'
continue_stmt= 'continue'
return_stmt= 'return' _ (testlist)?
yield_stmt= yield_expr
raise_stmt= 'raise' _ (test ('from' test)?)?
import_stmt= import_name / import_from
import_name= 'import' _ dotted_as_names

import_from= ('from' (('.' / '...')* dotted_name / ('.' / '...')+)
              'import' ('*' / '(' import_as_names ')' / import_as_names))
import_as_name= NAME ( _ 'as' _  NAME)?
dotted_as_name= dotted_name ( _ 'as' _ NAME)?
import_as_names= import_as_name (_ ',' _ import_as_name)* (',')?
dotted_as_names= dotted_as_name (_ ',' _ dotted_as_name)*
dotted_name= NAME ('.' NAME)*
global_stmt= 'global' NAME (',' NAME)*
nonlocal_stmt= 'nonlocal' NAME (',' NAME)*
assert_stmt= 'assert' test (',' test)?

compound_stmt= if_stmt / while_stmt / for_stmt / try_stmt / with_stmt / funcdef / classdef / decorated / async_stmt 
async_stmt= ASYNC (funcdef / with_stmt / for_stmt) 
if_stmt=  'if' _ test _ ':' suite ( SAMEDENT 'elif' _ test _ ':' suite)* ( SAMEDENT 'else' _ ':' _ suite)?
while_stmt= 'while' _ test ':' suite (SAMEDENT 'else' _ ':' _ suite)?
for_stmt= 'for' _ exprlist  _ 'in' _ testlist _ ':' _ suite (SAMEDENT 'else' _ ':' _ suite)?
try_stmt= ('try' _ ':' _ suite
           ((except_clause _ ':' _ suite)+
            ('else' _ ':' _ suite)?
            ('finally' _ ':' _ suite)?/
           'finally' _ ':' _ suite))
with_stmt= 'with' _ with_item _ (',' _ with_item)* _ ':' _ suite
with_item= test ( _ 'as' _ expr)?

except_clause= 'except' _ (test ( _ 'as' _ NAME)?)?
suite= simple_stmt / NEWLINE INDENT stmt (SAMEDENT stmt)* DEDENT

test=ot:or_test ('if' _ or_test _ 'else' _ test)? {
  return ot;
} / lambdef
test_nocond= or_test / lambdef_nocond

lambdef= 'lambda' _ (varargslist)? _ ':' _ test
lambdef_nocond= 'lambda' _ (varargslist)? _ ':' _ test_nocond

or_test= head:and_test tail:( _ 'or' _ and_test)* {
    var result = head, i;
  
  for (i = 0; i < tail.length; i++) {
    result = result || tail[i][3];
  }

  console.log(text()+" "+result);
  return result;
}
and_test= head:not_test tail:( _ 'and' _ not_test)* {
  var result = head, i;
  
  for (i = 0; i < tail.length; i++) {
    result = result && tail[i][3];
  }

  console.log(text()+" "+result);
  return result;
}

not_test='not' _ nt:not_test {
  return !nt;
} / comparison:comparison {
  return comparison;
}
comparison= head:expr tail:(_ comp_op _ expr)* {
  var result = head, i;
  
  for (i = 0; i < tail.length; i++) {
    switch(tail[i][1]) {
      case '>=':
        return result >= tail[i][3];
      case '<=':
        return result <= tail[i][3];
      case '<':
        return result < tail[i][3];
      case '>':
        return result > tail[i][3];
      case '==':
        return result == tail[i][3];
      case '!=':
        return result != tail[i][3];
      case 'in':
        //TODO or never do
      case 'not in':
        //TODO or never do
      case 'is':
        //TODO or never do
      case 'is not':
        //TODO or never do
    }
  }

  console.log(text()+" "+result);
  return result;
}

comp_op= '>='/'<='/'<'/'>'/'=='/'!='/'in'/('not' 'in')/'is'/('is' 'not')

//TODO or never do
star_expr= '*' _ expr {

}

expr= head:xor_expr tail:(_ '|' _ xor_expr)* {
  var result = head, i;
  
  for (i = 0; i < tail.length; i++) {
    result = result | tail[i][3];
  }

  console.log(text()+" "+result);
  return result;
}

xor_expr= head:and_expr tail:(_ '^' _ and_expr)* {
  var result = head, i;
  
  for (i = 0; i < tail.length; i++) {
    result = result ^ tail[i][3];
  }

  console.log(text()+" "+result);
  return result;
}

and_expr= head:shift_expr tail:(_ '&' _ shift_expr)* {
  var result = head, i;
  
  for (i = 0; i < tail.length; i++) {
    result = result & tail[i][3];
  }

  console.log(text()+" "+result);
  return result;
}

shift_expr= head:arith_expr tail:( _ ('<<'/'>>') _ arith_expr)* {
  var result = head, i;
  
  for (i = 0; i < tail.length; i++) {
    if (tail[i][1] === '<<') { result = result << tail[i][3]; }
    if (tail[i][1] === '>>') { result = result >> tail[i][3]; }
  }

  console.log(text()+" "+result);
  return result;
}

arith_expr= head:term tail:( _ ('+'/'-') _ term)* {
  var result = head, i;
  
  for (i = 0; i < tail.length; i++) {
    if (tail[i][1] === '+') { result += tail[i][3]; }
    if (tail[i][1] === '-') { result -= tail[i][3]; }
  }

  console.log(text()+" "+result);
  return result;
}

term= head:factor tail:( _ ('*'/'/'/'%') _ factor)* {
  var result = head, i;

  for (i = 0; i < tail.length; i++) {
    if (tail[i][1] === '*') { result *= tail[i][3]; }
    if (tail[i][1] === '/') { result /= tail[i][3]; }
    if (tail[i][1] === '%') { result %= tail[i][3]; }
  }
  console.log(text()+" "+result);
  return result;
}

factor= prefix:('+'/'-'/'~') factor:factor {
  if (prefix === '+') return factor;
  if (prefix === '-') return -factor;
  if (prefix === '~') return ~factor;
} / power:power {
  return power;
}

power= atom_expr:atom_expr ( _ '**' _ factor)? {
  return atom_expr;
}

atom_expr= (AWAIT)? atom:atom trailer* {
  return atom;
}

atom=
  '(' _ tc:(yield_expr/testlist_comp)? _ ')' {
    return tc;
  } / 
  '[' _ (testlist_comp)? _ ']' / 
  '{' _ (dictorsetmaker)? _ '}' / 
  NAME / 
  num:NUMBER {
    return num;
  } /
  STRING+ / 
  '...' / 
  'None' / 
  'True' / 
  'False'

//TODO
testlist_comp= t:(test/star_expr) ( comp_for / ( _ ',' _ (test/star_expr))* (',')? ) {
  return t;
}

trailer= '('  _ (arglist)? _ ')' / '[' _  subscriptlist _ ']' /'.' NAME
subscriptlist= subscript ( _ ',' _ subscript)* (',')?
subscript= test / (test)? ':' (test)? (sliceop)?
sliceop=':' (test)?
exprlist= (expr/star_expr) ( _ ',' _ (expr/star_expr))* (',')?
testlist= test ( _ ',' _ test)* (',')?
dictorsetmaker=( ((test _ ':' _ test /  '**' expr)
                   (comp_for / ( _ ',' _ (test _ ':' _  test / '**' expr))* (',')?)) /
                  ((test / star_expr)
                   (comp_for / ( _ ',' _ (test / star_expr))* (',')?)) )
                   
classdef= 'class' _ NAME ( '(' _ (arglist)? _ ')' )? _ ':' _ suite

arglist=argument ( _ ',' _ argument)*  (',')?

argument= ( test (comp_for)? /
            test '=' test /
            '**' test /
            '*' test )

comp_iter= comp_for / comp_if
comp_for= 'for' _ exprlist _ 'in' _ or_test (comp_iter)?
comp_if= 'if' _ test_nocond (comp_iter)?

encoding_decl= NAME

yield_expr= 'yield' _ (yield_arg)?
yield_arg='from' _ test / testlist

whitespace = "\t" / "\v" / "\f" / " " 
_  = whitespace*
NAME=[a-zA-Z][0-9a-zA-Z_]*
NEWLINE= "\r\n" / "\n" / "\r"
ENDMARKER= &{return true;} {return "END";}
ASYNC='async'
INDENT = i:[ \t]+ &{return i.length > indent.length;} {indentStack.push(indent);indent = i.join(""); }
SAMEDENT = i:[ \t]* &{
  if(i.join("") === indent)
    return true;
  else{
    //console.log('indent:'+indent.length);
    //console.log('current:'+i.join("").length);
    return false;
  }
}
DEDENT = &{return true;}{indent = indentStack.pop();}
AWAIT='await'

NUMBER=[+-]?([0-9]*[.])?[0-9]+ {
  //return new NumberObject(Number(text()));
  return Number(text());
}

STRING= '"' chars:DoubleStringCharacter* '"' {
  return text();
} / "'" chars:SingleStringCharacter* "'" {
  return text();
}

DoubleStringCharacter
  = !('"' / "\\" / LineTerminator) . { return text(); }

SingleStringCharacter
  = !("'" / "\\" / LineTerminator) . { return text(); }

LineTerminator
  = [\n\r\u2028\u2029]