// § genCaPsBoundOpChain254 (the part-select in a concatenation, a ternary branch, a reduction and a call argument)
module top #(parameter int W = 4) (input logic s, input logic [7:0] a, output logic [7:0] o [1], output logic [3:0] p [1], output logic q [1], output logic [3:0] r [1]);
  function automatic logic [3:0] id(logic [3:0] x); return x; endfunction
  for (genvar k = 0; k < 1; k++) begin : g
    assign o[k] = {a[W-1:W-4], a[2*W-1:W]};
    assign p[k] = s ? a[W+3:W] : a[W-1:0];
    assign q[k] = ^a[W-1:0];
    assign r[k] = id(a[W+3:W]);
  end
endmodule
