// ExpressionKind::Inside is in the law's op17 switch but has NO grid arm.
module top(input logic [31:0] a, output logic o);
  logic mv;
  if (1) begin : gb
    logic [31:0] src;
    assign src = a;
    assign mv = src inside {32'd1, 32'd2};
  end
  assign o = mv;
endmodule
