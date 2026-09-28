// § genCaCastRhsRefUnnamed198
module ch (input logic s, input logic [3:0] b, output logic [2:0] y [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign y[i] = 3'(b[i]);
  end
endmodule
module top (input logic s, input logic [3:0] b, output logic [2:0] y [2]);
  ch u (.s(s), .b(b), .y(y));
endmodule
