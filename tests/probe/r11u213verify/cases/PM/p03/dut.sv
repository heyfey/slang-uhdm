// § parenMethodCallPathSpan207 (module context: an interface instance's function and a class handle, parenthesized)
interface ifc ();
  function automatic int f(int a); return a + 1; endfunction
endinterface
class H;
  function int get(int i); return i; endfunction
endclass
module p03 (input int x, output int y, output int z);
  ifc u ();
  H h = new;
  assign y = (u.f(x));
  always_comb z = ((h.get(x)));
endmodule
