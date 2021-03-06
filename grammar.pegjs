{
  /*function debug(text, location){
    console.log(text);
  }*/
  var TYPES_TO_PROPERTY_NAMES = {
    CallExpression:   "callee",
    MemberExpression: "object",
  };
  
  function filledArray(count, value) {
    return Array.apply(null, new Array(count))
      .map(function() { return value; });
  }

  function extractOptional(optional, index) {
    return optional ? optional[index] : null;
  }

  function extractList(list, index) {
    return list.map(function(element) { return element[index]; });
  }
  
  function buildList(head, tail, index) {
    return [head].concat(extractList(tail, index));
  }
  
  function buildBinaryExpression(head, tail) {
    return tail.reduce(function(result, element) {
      return {
        type: "BinaryExpression",
        operator: element[1],
        left: result,
        right: element[3]
      };
    }, head);
  }
  
  function buildLogicalExpression(head, tail) {
    return tail.reduce(function(result, element) {
      return {
        type: "LogicalExpression",
        operator: element[1],
        left: result,
        right: element[3]
      };
    }, head);
  }

  function optionalList(value) {
    return value !== null ? value : [];
  }
  
  function buildList1(head,index){
    return head ? extractList(head,index):null
  }
  var indentStack = [], indent = "";
}
Start
  = file_input
  
/*single_input= NEWLINE / simple_stmt / compound_stmt NEWLINE*/ 
file_input= (NEWLINE / stmt)* ENDMARKER 
/*eval_input= testlist NEWLINE* ENDMARKER */

decorator= '@' dotted_name ( '('_ (arglist)? _')' )? NEWLINE
decorators= decorator+
decorated= decorators (classdef / funcdef / async_funcdef)

async_funcdef= ASYNC _ funcdef
funcdef='def' _ id:NAME params:parameters ('->'_ test)? _ ':' _ body:suite 
{
      return {
        type: "FunctionDeclaration",
        id: id,
        params: params,
        body: body
      };
    }
parameters= '('_ head:(typedargslist)? _')'{return head;}
typedargslist= (head:tfpdef ('=' test)? tail:(','  tfpdef ('=' test)?)* (','
       ('*' (tfpdef)? (',' tfpdef ('=' test)?)* (',' '**' tfpdef)? / '**' tfpdef)?)?
       {
          return buildList(head,tail,1);
       }
     /  '*' (tfpdef)? (',' tfpdef ('=' test)?)* (',' '**' tfpdef)? / '**' tfpdef)
tfpdef=head:NAME (':' test)?
{
 return head[0];
}
varargslist= (vfpdef ('=' test)? (',' vfpdef ('=' test)?)* (','
       ('*' (vfpdef)? (',' vfpdef ('=' test)?)* (',' '**' vfpdef)? / '**' vfpdef)?)?
     /  '*' (vfpdef)? (',' vfpdef ('=' test)?)* (',' '**' vfpdef)? / '**' vfpdef)
vfpdef= NAME

stmt= simple_stmt /*{debug(text(),location()); return text();}*/
    / compound_stmt /*{debug(text(),location()); return text();}*/
simple_stmt= head:(small_stmt) tail:(_ ';'_ small_stmt)* (';')? NEWLINE
  {
      return tail.length > 0
        ? { type: "SequenceExpression", expressions: buildList(head, tail, 3) }
        : head;
    }
small_stmt= global_stmt/flow_stmt/expr_stmt
expr_stmt= left:testlist_star_expr  _ operator:augassign _ right:(yield_expr/testlist)
  { 
  return {
        type: "AssignmentExpression",
        operator: operator,
        left: left,
        right: right
      };} 
 /head:testlist_star_expr _ tail:(_ '=' _ (yield_expr/testlist_star_expr))*
 { return buildBinaryExpression(head, tail);}
    
testlist_star_expr= head:(test/star_expr) (',' (test/star_expr))* (',')?{return head;}
augassign=('+=' / '-=' / '*=' / '@=' / '/='/ '%=' / '&=' / '|=' / '^=' /
            '<<=' / '>>=' / '**=' / '//=')
            
            
del_stmt='del' exprlist
pass_stmt= 'pass'
flow_stmt= break_stmt / continue_stmt / return_stmt / raise_stmt / yield_stmt
break_stmt
='break'{return { type: "BreakStatement", label: null }; }
continue_stmt= 'continue'{
	return {type:"continue"};
    }
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
global_stmt='global'_ head:NAME tail:(',' NAME)*
{
  return{
    type: 'global',
    name: buildList(head,tail,1)
  };
}
nonlocal_stmt= 'nonlocal' NAME (',' NAME)*
assert_stmt= 'assert' test (',' test)?

compound_stmt= if_stmt / while_stmt / for_stmt / try_stmt / with_stmt / funcdef / classdef / decorated / async_stmt 
async_stmt= ASYNC (funcdef / with_stmt / for_stmt) 



if_stmt
  = head:('if' _ test _ ':' suite) mid:( SAMEDENT 'elif' _ test _ ':' suite)*  tail:( SAMEDENT 'else' _ ':' _ suite)?
   {    return {
           type:"IfStatement",
           test:head[2],
           consequent:head[5],
           
           eliftest:buildList1(mid,3), 
           elifalternative:buildList1(mid,6),
           alternative: extractOptional(tail, 5)
       }
       
   }
while_stmt
  = 'while' _ test:test ':' body:suite (SAMEDENT 'else' _ ':' _ suite)?
{
  return { type: "WhileStatement", test: test, body: body }; }
for_stmt
  = 'for' _ init:exprlist  _ 'in' _ test:testlist _ ':' _ body:suite tail:(SAMEDENT 'else' _ ':' _ suite)?
 {
      return {
        type: "ForStatement",
        init: init,
        test: test,
        body: body
      };
    }

try_stmt= ('try' _ ':' _ suite
           ((except_clause _ ':' _ suite)+
            ('else' _ ':' _ suite)?
            ('finally' _ ':' _ suite)?/
           'finally' _ ':' _ suite))
with_stmt= 'with' _ with_item _ (',' _ with_item)* _ ':' _ suite
with_item= test ( _ 'as' _ expr)?

except_clause= 'except' _ (test ( _ 'as' _ NAME)?)?
suite= head:simple_stmt {return head;} / NEWLINE INDENT left:stmt right:(SAMEDENT stmt)* DEDENT
{return buildList(left, right, 1);} 

test=head:or_test ('if' _ or_test _ 'else' _ test)? {return head;}/lambdef
test_nocond= or_test / lambdef_nocond
lambdef= 'lambda' _ (varargslist)? _ ':' _ test
lambdef_nocond= 'lambda' _ (varargslist)? _ ':' _ test_nocond
or_test= head:and_test tail:( _ 'or' _ and_test)* {return buildBinaryExpression(head, tail);}
and_test= head:not_test tail:( _ 'and' _ not_test)* {return buildBinaryExpression(head, tail);}
not_test='not' _ not_test /comparison
comparison= head:expr _ tail:(_ comp_op _ expr)*
{return buildBinaryExpression(head, tail);}

comp_op= '>='/'<='/'<'/'>'/'=='/'<>'/'!='/'in'/('not' 'in')/'is'/('is' 'not')
star_expr= '*' _ expr
expr= head:xor_expr tail:(_ '|' _ xor_expr)*
{ 
  return buildLogicalExpression(head, tail);
}
xor_expr= head:and_expr tail:(_ '^' _ and_expr)* {return buildLogicalExpression(head, tail);}
and_expr= head:shift_expr tail:(_ '&' _ shift_expr)*{return buildLogicalExpression(head, tail);}
shift_expr= head:arith_expr tail:( _ ('<<'/'>>') _ arith_expr)*{return buildLogicalExpression(head, tail);}
arith_expr= head:term tail:( _ ('+'/'-') _ term)*{return buildBinaryExpression(head, tail);}
term= head:factor tail:( _ ('*'/'@'/'/'/'%'/'//') _ factor)*{return buildBinaryExpression(head, tail); }
factor= ('+'/'-'/'~') factor / power
power= head:atom_expr tail:( _ '**' _ factor)?
{ 
  return head;
    }
atom_expr= (AWAIT)? mid:atom tail:trailer*
{return {atom:mid,
         trailer:tail.length>0?tail:null}};
atom= '(' _ head:(yield_expr/testlist_comp)? _ ')' 
{
  return head;
}/
       '[' _ head:(testlist_comp)? _ ']' 
       {
          return {  type: "List",
                    content:head
          };
       }/
       '{' _ head:(dictorsetmaker)? _ '}' 
       {
          return head;
       }/
       head:(NAME / NUMBER / STRING+ / '...' / 'None' / 'True' / 'False')
      {return head;}
      
testlist_comp= head:(test/star_expr)  tail:( _ ',' _ (test/star_expr))* (',')? 
{return buildList(head,tail,3);}

trailer= '('  _ head:(arglist)? _ ')' 
{return {
         type:"arglist",
		 body:head 
         };
   }

/ '[' _  body:subscriptlist _ ']' 
{
      return {
        type: "subscript",
        body: body
      };
    }

/'.' head:NAME
{ 
	return {
    	type:"member",
        body:head
    }
}

subscriptlist= head:subscript tail:( _ ',' _ subscript)* (',')?
{return buildList(head,tail,3);}

subscript= head:test 
{return head;}
/ (test)? ':' (test)? (sliceop)?
{
    

}
sliceop=':' (test)? 
exprlist= head:(expr/star_expr) tail:( _ ',' _ (expr/star_expr))* (',')?
{return buildLogicalExpression(head, tail);}

testlist= head:test tail:( _ ',' _ test)* (',')?
{return buildList(head, tail,3);}
dictorsetmaker=( ((test _ ':' _ test /  '**' expr)
                   (comp_for / ( _ ',' _ (test _ ':' _  test / '**' expr))* (',')?)) /
                  ((test / star_expr)
                   (comp_for / ( _ ',' _ (test / star_expr))* (',')?)) )
                   
classdef= 'class' _ NAME ( '(' _ (arglist)? _ ')' )? _ ':' _ suite

arglist=head:argument tail:( _ ',' _ argument)*  (',')?
{return buildList(head, tail,3);}
argument= ( head:test (comp_for)? {return head;}/
            test '=' test /
            '**' test /
            '*' test )

comp_iter= comp_for / comp_if
comp_for= 'for' _ exprlist _ 'in' _ or_test (comp_iter)?
comp_if= 'if' _ test_nocond (comp_iter)?


encoding_decl= NAME

yield_expr= 'yield' _ (yield_arg)?{return 'yield';}
yield_arg='from' _ test / testlist

whitespace = "\t" / "\v" / "\f" / " " 
_  = whitespace*
NAME=head:[a-zA-Z]tail:[0-9a-zA-Z_]*{
  var output=head;
  var i;
  for(i=0;i<tail.length;i++)
  {
    output+=tail[i]
  }
return output;}
NEWLINE=&{}"\r\n" / "\n" / "\r"
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
NUMBER=one:[+-]?two:([0-9]*[.])?three:[0-9]+{
  var output="";
  var i;
  if(one)
  {
     output+=one;
  }
  if(two)
  {
     output+=two;
  }
  for(i=0;i<three.length;i++)
  {
     output+=three[i];
  }
  return output;}
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