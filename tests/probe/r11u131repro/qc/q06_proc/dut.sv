// § pkgQualCallQualSpan131
package p;
  function automatic int f(int a); return a + 1; endfunction
  function automatic int g(); return 3; endfunction
endpackage
module top (input int i, output int o);
  always_comb o = p::f(i);
endmodule
