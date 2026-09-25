// ARR: a whole-name Lhs first (a ref, skipped by the scan), then a select.
module top(input logic a, output logic [3:0] y);
  logic [3:0] v;
  always_comb begin
    v = 4'h0;
    v[2] = a;
    y = v;
  end
endmodule
