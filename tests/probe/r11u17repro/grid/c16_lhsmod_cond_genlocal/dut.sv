module top(input logic [31:0] a, input logic sel, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] src;
    assign src = a;
    assign mv = sel ? src : 32'd0;
  end
  assign o = mv;
endmodule
