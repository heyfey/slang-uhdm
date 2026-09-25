// ARR: the select Lhs sits under an if (not a direct statement of the begin).
module top(input logic a, input logic c, output logic [3:0] y);
  logic [3:0] v;
  always_comb begin
    v = 4'h0;
    if (c) v[0] = a;
    y = v;
  end
endmodule
