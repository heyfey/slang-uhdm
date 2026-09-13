// ORDER REVERSED: the gen-local-Lhs assign comes FIRST.
module top(input logic [31:0] a, input logic [31:0] b, output logic [31:0] o, output logic [31:0] o2);
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] src;
    logic [31:0] loc;
    assign src = a;
    assign loc = src ^ b;
    assign mv  = src | 32'd1;
    assign o2  = loc;
  end
  assign o = mv;
endmodule
