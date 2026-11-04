// ARR: the select Lhs comes AFTER the whole read (the scan covers every
// direct statement of the block).
module top(input logic a, output logic [3:0] y);
  logic [3:0] v;
  always_comb begin
    y = v;
    v[0] = a;
  end
endmodule
