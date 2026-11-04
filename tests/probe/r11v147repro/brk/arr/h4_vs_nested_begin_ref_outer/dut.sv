// § blockLhsVarSelBindsWholeRef151
module top(input logic c, input logic a, output logic [1:0][1:0] y);
  logic [1:0][1:0] v;
  always_comb begin
    v = '0;
    begin
      v[1][0] = a;
    end
    y = v;
  end
endmodule
