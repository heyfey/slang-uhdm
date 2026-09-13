// A CONCATENATION Lhs is not a ref_obj: writeCont_assign's bind arm never runs.
module top(input logic [31:0] a, output logic [15:0] x, output logic [15:0] y);
  logic [15:0] mx, my;
  if (1) begin : gb
    logic [31:0] src;
    assign src = a;
    assign {mx, my} = src | 32'd1;
  end
  assign x = mx; assign y = my;
endmodule
