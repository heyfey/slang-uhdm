// § bodyParamNoHdrList262v (an if-generate reading a longer name that holds the parameter's name as a prefix; the parameter read outside)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q, output logic [1:0] r);
  localparam int K = 2;
  localparam int K_2 = 1;
  assign r = a[K +: 2];
  if (E) begin : g
    assign q = a[K_2 +: 2];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q, output logic [1:0] r);
  ctrl u (.a(a), .q(q), .r(r));
endmodule
