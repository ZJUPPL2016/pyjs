$(document).ready(function() {
    var grammar = $("#grammar").text();
    var parser  = peg.generate(grammar);
    
    $("#submit").click(function(){
        $("#output").val("");
        var input = $("#input").val();
        try {
            var result = parser.parse(input);
            console.log("succeed");
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
