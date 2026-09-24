module top(input logic [15:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gb
    logic [15:0] src;
    assign src = a;
    assign mv = 32'(src);
  end
  assign o = mv;
endmodule
