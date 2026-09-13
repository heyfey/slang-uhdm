module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  for (genvar i = 0; i < 2; i++) begin : gf
    logic [31:0] loc;
    assign mv  = a;
    assign loc = mv;
  end
  assign o = mv;
endmodule
