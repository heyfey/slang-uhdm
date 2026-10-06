// § bodyParamNoHdrList262v (body localparam read only in the not-taken branch of an if-generate)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; #(parameter bit E = 0) (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  if (E) begin : g
    assign q = a[K +: 2];
  end else begin : gn
    assign q = a[1:0];
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
