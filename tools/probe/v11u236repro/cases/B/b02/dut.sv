// § caOpArgIntFormalTs236 — operation actuals: ternary, concatenation, unary, comparison, net and parameter mixed, integer/shortint/byte formals
module top #(parameter int P = 4) (input int a, input logic c, input logic [3:0] v, output int o, output int o2, output int o3);
  localparam int L = 2;
  function automatic int h(int x, integer k);
    return x + k;
  endfunction
  function automatic int g(shortint s, byte b);
    return s - b;
  endfunction
  assign o = h(c ? a : P, {v, v});
  assign o2 = g(a + P, ~v);
  assign o3 = h(a == L, v * L) + g(-a, !c);
endmodule
