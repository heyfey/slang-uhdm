// § unitImpTransitiveTds464 (a program in the importing file)
package a;
  typedef logic [3:0] a_t;
endpackage
package m;
  import a::*;
endpackage
import m::*;
program prg;
  initial $display("x");
endprogram
module top(input logic [1:0] i, output logic [1:0] o);
  prg p();
  assign o = i;
endmodule
