// ARR: a range select of an element select as the Lhs (the var_select whose
// last index is a part_select).
module top(input logic [1:0] a, output logic [3:0] o);
  logic [3:0] pa [2];
  logic [3:0] pb [2];
  always_comb begin
    pa[0][1:0] = a;
    pa[0][3:2] = 2'b0;
    pa[1] = 4'h0;
    pb = pa;
    o = pb[0];
  end
endmodule
