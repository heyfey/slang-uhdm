// § defImpArithSize32_409
package p;
  localparam bit [7:0] W = 5;
  parameter R = W ? W : W;
endpackage
import p::*;
module top;

endmodule
