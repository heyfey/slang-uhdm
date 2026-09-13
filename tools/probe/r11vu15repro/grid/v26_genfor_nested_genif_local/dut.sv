module top(input logic clk, input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  for (genvar i = 0; i < 2; i++) begin : gf
    if (1) begin : gi
      logic [31:0] loc;
      logic [31:0] src;
      assign src = a;
      assign loc = src;
      assign mv  = a;
    end
  end
  assign o = mv;
endmodule
