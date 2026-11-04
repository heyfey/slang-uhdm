// ARR: an indexed part-select Lhs.
module top(input logic [1:0] a, input logic [1:0] i, output logic [7:0] y);
  logic [7:0] v;
  always_comb begin
    v = '0;
    v[i*2 +: 2] = a;
    y = v;
  end
endmodule
