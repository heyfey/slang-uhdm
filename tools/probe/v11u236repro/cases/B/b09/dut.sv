// § caOpArgIntFormalTs236 — operation actuals in the branches of a conditional
module top #(parameter int P = 2) (input int a, input logic [7:0] v, output int o);
  function automatic int f(int x);
    return x;
  endfunction
  assign o = a > 0 ? f(a - 1) : f(-a);
endmodule
