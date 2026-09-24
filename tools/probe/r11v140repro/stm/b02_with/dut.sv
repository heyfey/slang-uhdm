// § streamOperandBraceSpan140
module top(input logic [7:0] a, output logic [7:0] o);
  byte q[4];
  always_comb begin
    q = '{1,2,3,4};
    o = { << byte { q with [0 +: 1] } };
  end
endmodule
