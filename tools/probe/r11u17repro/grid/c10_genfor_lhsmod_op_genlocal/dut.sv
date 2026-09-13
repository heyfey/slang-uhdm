module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv[2];
  for (genvar i = 0; i < 2; i++) begin : gb
    logic [31:0] src;
    assign src = a;
    assign mv[i] = src | 32'd1;
  end
  assign o = mv[0] ^ mv[1];
endmodule
