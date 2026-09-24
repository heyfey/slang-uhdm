module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gb
    logic [15:0] loc;
    assign loc = mv[15:0];
    assign mv  = a;
  end
  assign o = mv;
endmodule
