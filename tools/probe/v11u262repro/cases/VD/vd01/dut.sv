// § bodyParamNoHdrList262v (body localparam read inside an if-generate nested in a for-generate)
package rp;
  localparam int K = 2;
endpackage
module ctrl import rp::*; #(parameter bit E = 1) (input logic [7:0] a, output logic [1:0] q);
  localparam int K = 2;
  for (genvar h = 0; h < 1; h++) begin : gf
    if (E) begin : g
      assign q = a[4 +: K];
    end
  end
endmodule
module top(input logic [7:0] a, output logic [1:0] q);
  ctrl u (.a(a), .q(q));
endmodule
