// § opArgCallCtx236v — a call with an operation actual reading a net, as an operand of an operation
module top #(parameter int P = 2) (input int a, input logic [7:0] v, output int o);
  function automatic int f(int x);
    return x;
  endfunction
  assign o = f(a + 1) + 1;
endmodule
