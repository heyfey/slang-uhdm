module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] loc;
    always_comb mv = a;
    assign loc = mv;
  end
  assign o = mv;
endmodule
