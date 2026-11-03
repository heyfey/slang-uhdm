// § modImpCopyTdChainHomeTop473
// function call argument
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  import b::*;
  function automatic logic [3:0] inc(input logic [3:0] v); return v + 1; endfunction
  assign y = inc(PB);
endmodule
