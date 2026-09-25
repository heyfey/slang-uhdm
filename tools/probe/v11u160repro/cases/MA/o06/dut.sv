// § objMacroParenArgsTrimmed160
`define D foo
module top (output logic [3:0] d);
  function automatic logic [3:0] foo(input logic [3:0] x, input logic [3:0] y); return x + y; endfunction
  assign d = `D ( 4'h2, 4'h3 ) ;
endmodule
