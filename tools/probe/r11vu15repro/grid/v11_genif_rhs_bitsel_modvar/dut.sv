module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] loc;
    assign mv     = a;
    assign loc[0] = mv[0];
  end
  assign o = mv;
endmodule
