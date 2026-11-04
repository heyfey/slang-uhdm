// § blockLhsVarSelBindsWholeRef151
module top(input logic c, input logic a, output logic [1:0][1:0] y);
  logic [1:0][1:0] v;
  always_comb begin
    v = '0;
    if (c) v[0][1] = a;
    y = v;
  end
endmodule
