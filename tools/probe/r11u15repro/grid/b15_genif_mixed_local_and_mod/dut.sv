module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] src;
    logic [31:0] loc;
    assign src = a;
    assign loc = src | mv;
  end
  assign mv = a;
  assign o = mv;
endmodule
