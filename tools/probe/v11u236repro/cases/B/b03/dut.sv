// § caOpArgIntFormalTs236 — operation actuals in a for-generate continuous assignment, a generate net decl, and a part-select bound
module top #(parameter int P = 2) (input int a, input logic [15:0] v, output int o[3], output logic [3:0] o2);
  function automatic int h(int x, int k);
    return x + k;
  endfunction
  for (genvar i = 0; i < 3; i++) begin : gl
    wire [31:0] w = h(a + i, a - P);
    assign o[i] = w;
  end
  assign o2 = v[h(P, 1) +: 4] ^ v[h(P + 1, P * 2) -: 4];
endmodule
