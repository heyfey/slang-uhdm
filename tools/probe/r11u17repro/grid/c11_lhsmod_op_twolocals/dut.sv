module top(input logic [31:0] a, output logic [31:0] o);
  logic [31:0] mv;
  if (1) begin : gb
    logic [31:0] s1, s2;
    assign s1 = a;
    assign s2 = a;
    assign mv = s1 | s2;
  end
  assign o = mv;
endmodule
