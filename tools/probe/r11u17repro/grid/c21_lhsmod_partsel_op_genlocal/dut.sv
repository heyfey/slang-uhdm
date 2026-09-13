module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] src;
    assign src = a;
    assign mv[15:0] = src[15:0] | 16'd1;
  end
  assign o = mv;
endmodule
