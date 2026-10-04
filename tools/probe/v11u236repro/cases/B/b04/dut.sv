// § caOpArgIntFormalTs236 — int unsigned and longint formals with net operations, a call result operation, a cast operand
module top (input int a, input logic [7:0] v, output longint o, output int o2);
  function automatic longint h(int unsigned x, longint k);
    return x + k;
  endfunction
  function automatic int f(int x);
    return x;
  endfunction
  assign o = h(a + 1, v - 8'd1);
  assign o2 = f(f(a) + 1) + f(int'(v) * 2) + f(v[3:0] + v[7:4]);
endmodule
