// § defImpArithSize32_409
package p;
  localparam bit [3:0] A = 4'd2;
  parameter R = A ? 4'd1 : 4'd7;
endpackage
module top (output [3:0] o);
  import p::*;
  assign o = R;
endmodule
