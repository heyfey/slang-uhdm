// § parenCallCallee479
package p;
  function automatic int pf(int a, int b = 2); return a + b; endfunction
endpackage
module top(output int z);
  initial z = (p::pf(1));
endmodule
