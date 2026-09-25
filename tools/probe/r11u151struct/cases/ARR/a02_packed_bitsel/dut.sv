// ARR: a packed vector written by bit and read whole in the same begin.
module top(input logic a, input logic [2:0] b, output logic [3:0] y);
  logic [3:0] v;
  always_comb begin
    v[0] = a;
    v[3:1] = b;
    y = v;
  end
endmodule
