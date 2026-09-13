module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv, mv2;
  if (1) begin : gb
    logic [31:0] loc, loc2;
    assign loc  = mv;
    assign loc2 = loc;
  end
  assign mv  = a;
  assign mv2 = a;
  assign o = mv;
endmodule
