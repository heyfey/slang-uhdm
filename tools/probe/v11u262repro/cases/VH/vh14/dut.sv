// § bodyParamNoHdrList262v (vh06 with the header parameter overridden to a different value)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q, output logic [1:0] r);
  localparam int K = 2;
  assign r = a[K +: 2];
  assign q = a[1:0] & {2{E}};
endmodule
module top(input logic [7:0] a, output logic [1:0] q, output logic [1:0] r);
  ctrl #(.E(0)) u (.a(a), .q(q), .r(r));
endmodule
