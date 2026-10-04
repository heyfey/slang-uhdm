// § opArgCallCtx236v — an operation actual of part selects, the call an operand of an operation
module top #(parameter int P = 2) (input int a, input logic [7:0] v, output int o);
  function automatic int f(int x);
    return x;
  endfunction
  assign o = f(v[3:0] + v[7:4]) ^ a;
endmodule
