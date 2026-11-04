// § defImpArithSize32_409
package p;
  localparam bit [27:0] W = 5;
  parameter R = W|W;
endpackage

module top;
  import p::*;
endmodule
