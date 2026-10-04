// § opArgCallCtx236v — operation actuals in a port connection, with a genvar in a for-generate, and in an interface body
interface ifc (input int a);
  function automatic int f(int x);
    return x;
  endfunction
  int v;
  assign v = f(a + 1);
endinterface
module sub (input int i, output int o);
  assign o = i;
endmodule
module top (input int a, output int o, output int o2, output int o3[2]);
  function automatic int f(int x);
    return x;
  endfunction
  ifc u_i (.a(a));
  sub u_s (.i(f(a * 2)), .o(o));
  assign o2 = u_i.v;
  for (genvar i = 0; i < 2; i++) begin : gl
    assign o3[i] = f(a + i);
  end
endmodule
