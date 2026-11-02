// § procAsgRhsPkgFoldTs471
// module function body (alias reference name residue)
package a;
  typedef logic [3:0] t;
  parameter t PA = 4'd9;
  parameter logic [3:0] PB = 4'd5;
  parameter PU = 7;
  typedef enum logic [1:0] {I0, I1, I2} e_t;
  parameter e_t PE = I2;
endpackage
module top(output logic [3:0] y);
  import a::*;
  function automatic logic [3:0] f(); logic [3:0] v; v = PA; return v; endfunction
  assign y = f();
endmodule
