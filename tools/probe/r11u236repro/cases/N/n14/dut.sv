// § caOpArgIntFormalTs236 — operation actuals of int formals: nets, parameters only, a part select, a unary minus, a vector formal
module top #(parameter int P = 2) (input int a, input logic [7:0] v, output int o, output int o2, output int o3);
  localparam int L = 3;
  function automatic int h(int x, int k);
    return x + k;
  endfunction
  function automatic int g(logic [7:0] q, int k);
    return q + k;
  endfunction
  assign o = h(a + 1, P + L);
  assign o2 = h(v[3:0] + a, -a);
  assign o3 = g(v & 8'hf, a * P);
endmodule
