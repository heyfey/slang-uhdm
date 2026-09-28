// § namedUnlinkedWrittenOrder207 (package functions: a caller above its callee in the same package; a module function above its callee)
package p;
  function automatic int g(int x);
    return f(.c(x), .a(1));
  endfunction
  function automatic int f(int a, int b = 1, int c = 2);
    return a + b + c;
  endfunction
endpackage
module top (input int x, output int o);
  function automatic int h(int y);
    return k(.b(y), .a(2));
  endfunction
  function automatic int k(int a, int b = 4, int c = 6);
    return a + b + c;
  endfunction
  assign o = h(x) + p::g(x);
endmodule
