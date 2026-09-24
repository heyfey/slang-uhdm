module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] loc;
    assign loc = mv | 32'd1;
    assign mv  = a;
  end
  assign o = mv;
endmodule
