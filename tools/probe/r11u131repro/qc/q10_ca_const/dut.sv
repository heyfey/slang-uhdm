// § pkgQualCallQualSpan131
package p;
  function automatic int f(int a); return a + 1; endfunction
  function automatic int g(); return 3; endfunction
endpackage
module top (output int o);
  assign o = p::f(2);
endmodule
