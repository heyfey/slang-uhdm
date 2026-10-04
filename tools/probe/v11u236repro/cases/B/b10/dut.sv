// § caOpArgIntFormalTs236 — operation actuals in a concatenation and a comparison
module top #(parameter int P = 2) (input int a, input logic [7:0] v, output int o);
  function automatic int f(int x);
    return x;
  endfunction
  assign o = {f(a * 2), f(a + P)} != 0;
endmodule
