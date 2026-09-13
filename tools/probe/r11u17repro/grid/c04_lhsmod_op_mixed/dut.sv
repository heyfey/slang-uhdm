module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv, mw;
  if (1) begin : gb
    logic [31:0] src;
    assign src = a;
    assign mv  = src | mw;
  end
  assign mw = a;
  assign o = mv;
endmodule
