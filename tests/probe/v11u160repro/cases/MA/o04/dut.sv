// § objMacroParenArgsTrimmed160
`define D foo
module top (output logic [3:0] d);
  function automatic logic [3:0] foo(input logic [3:0] x); return x + 1; endfunction
  assign d = `D ( 4'h2 ) ;
endmodule
