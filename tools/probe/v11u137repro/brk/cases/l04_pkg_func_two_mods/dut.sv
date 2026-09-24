// § elabCloneFullNameUnstored137
package pk;
  function automatic int add(input int a, input int b);
    int s;
    s = a + b;
    return s;
  endfunction
endpackage
module sub(output int o);
  assign o = pk::add(1, 2);
endmodule
module top(output int o, output int p);
  sub u(.o(o));
  assign p = pk::add(3, 4);
endmodule
