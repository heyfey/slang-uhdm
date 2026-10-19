// § defImpArithSize32_409
package p;
  parameter R = 40'h1 << 35;
endpackage
import p::*;
module top (output [39:0] o);
  assign o = R;
endmodule
