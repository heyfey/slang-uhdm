// § constPathBaseAnyKind146
module top(input logic [3:0] d, output logic [3:0] q);
  generate if (1) begin : g
    localparam W = 4;
  end endgenerate
  logic [g.W-1:0] v;
  assign v = d; assign q = v;
endmodule
