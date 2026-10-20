// § stdRandomizeFuncCall413
package pk;
  function automatic int g();
    int a, b;
    if (!randomize(a, b)) return -1;
    return a + b;
  endfunction
endpackage
module top(output int r);
  initial r = pk::g();
endmodule
