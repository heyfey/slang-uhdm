// § modImpCopyTdChainHomeTop473
// module function returns PB
package a;
  typedef logic [3:0] t;
endpackage
package b;
  import a::*;
  parameter t PB = 5;
endpackage
module top(output logic [3:0] y);
  import b::*;
  function automatic logic [3:0] f(); return PB; endfunction
  assign y = f();
endmodule
