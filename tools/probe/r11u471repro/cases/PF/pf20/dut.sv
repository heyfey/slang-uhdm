// § procAsgRhsPkgFoldTs471
// CONTROL class in a module (abstains)
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
  class C; logic [3:0] m; function void s(); m = PA; endfunction endclass
  initial begin C c = new; c.s(); y = c.m; end
endmodule
