// § opArgCallCtx236v — an operation actual in a port connection (b11 alone)
module sub (input int i, output int o);
  assign o = i;
endmodule
module top (input int a, output int o);
  function automatic int f(int x);
    return x;
  endfunction
  sub u_s (.i(f(a * 2)), .o(o));
endmodule
