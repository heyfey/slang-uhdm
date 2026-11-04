// ARR: the whole read is an if condition directly in the begin.
module top(input logic a, output logic y);
  logic [3:0] v;
  always_comb begin
    v[0] = a;
    v[3:1] = 3'b0;
    y = 1'b0;
    if (v) y = 1'b1;
  end
endmodule
