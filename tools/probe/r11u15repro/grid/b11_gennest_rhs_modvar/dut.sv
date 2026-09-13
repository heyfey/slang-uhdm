module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : g1
    if (1) begin : g2
      logic [31:0] loc;
      assign loc = mv;
    end
  end
  assign mv = a;
  assign o = mv;
endmodule
