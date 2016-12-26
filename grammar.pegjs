{
  function debug(text, location){
    console.log(text);
  }
  var indentStack = [], indent = "";
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

test=or_test ('if' _ or_test _ 'else' _ test)? /lambdef
test_nocond= or_test / lambdef_nocond
lambdef= 'lambda' _ (varargslist)? _ ':' _ test
lambdef_nocond= 'lambda' _ (varargslist)? _ ':' _ test_nocond
or_test= and_test ( _ 'or' _ and_test)*
and_test= not_test ( _ 'and' _ not_test)*
not_test='not' _ not_test /comparison
comparison= expr (_ comp_op _ expr)*

comp_op= '>='/'<='/'<'/'>'/'=='/'<>'/'!='/'in'/('not' 'in')/'is'/('is' 'not')
star_expr= '*' _ expr
expr= xor_expr (_ '|' _ xor_expr)*
xor_expr= and_expr (_ '^' _ and_expr)*
and_expr= shift_expr (_ '&' _ shift_expr)*
shift_expr= arith_expr ( _ ('<<'/'>>') _ arith_expr)*
arith_expr= term ( _ ('+'/'-') _ term)*
term= factor ( _ ('*'/'@'/'/'/'%'/'//') _ factor)*
factor= ('+'/'-'/'~') factor / power
power= atom_expr ( _ '**' _ factor)?
atom_expr= (AWAIT)? atom trailer*
atom= ('(' _ (yield_expr/testlist_comp)? _ ')' /
       '[' _ (testlist_comp)? _ ']' /
       '{' _ (dictorsetmaker)? _ '}' /
       NAME / NUMBER / STRING+ / '...' / 'None' / 'True' / 'False')
testlist_comp= (test/star_expr) ( comp_for / ( _ ',' _ (test/star_expr))* (',')? )
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
NUMBER=[+-]?([0-9]*[.])?[0-9]+
STRING
  = '"' chars:DoubleStringCharacter* '"' {
      return { type: "Literal", value: chars.join("") };
    }
  / "'" chars:SingleStringCharacter* "'" {
      return { type: "Literal", value: chars.join("") };
    }

DoubleStringCharacter
  = !('"' / "\\" / LineTerminator) . { return text(); }

SingleStringCharacter
  = !("'" / "\\" / LineTerminator) . { return text(); }

LineTerminator
  = [\n\r\u2028\u2029]