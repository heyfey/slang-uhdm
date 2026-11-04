// § caOpArgIntFormalTs236 — an operation actual holding a call that reads a net
module top #(parameter int P = 2) (input int a, input logic [7:0] v, output int o);
  function automatic int f(int x);
    return x;
  endfunction
  assign o = f(f(a) + 1);
endmodule
