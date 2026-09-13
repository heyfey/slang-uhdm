module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  always_comb mv = a;
  if (1) begin : gb
    logic [31:0] loc;
    assign loc = mv;
  end
  assign o = mv;
endmodule
