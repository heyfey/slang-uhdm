// § namedUnlinkedWrittenOrder207 (a callee in ANOTHER package: scoped, explicitly imported, wildcard imported; from a class and from a module)
package q;
  function automatic int f(int a, int b = 1, int c = 2);
    return a * 100 + b * 10 + c;
  endfunction
  function automatic int f2(int a, int b = 1, int c = 2);
    return a + b + c;
  endfunction
endpackage
package p;
  import q::f2;
  class K;
    function int g(int x);
      return q::f(.c(x), .a(1)) + f2(.b(x), .a(3));
    endfunction
  endclass
endpackage
module top (input int x, output int o, output int r);
  import q::*;
  assign o = f(.c(x), .b(2), .a(1));
  always_comb r = q::f2(.c(4), .a(x));
endmodule
