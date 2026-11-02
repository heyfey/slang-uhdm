// § procAsgRhsPkgFoldTs471
// CONTROL package function (abstains)
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
  parameter logic [3:0] PB = 4'd5;
  parameter PU = 7;
  typedef enum logic [1:0] {I0, I1, I2} e_t;
  parameter e_t PE = I2;
endpackage
package b;
  import a::*;
  function automatic logic [3:0] g(); logic [3:0] v; v = PA; return v; endfunction
endpackage
module top(output logic [3:0] y);
  assign y = b::g();
endmodule
