// § pkgQualCallQualSpan131
package p;
  function automatic int f(int a); return a + 1; endfunction
  function automatic int g(); return 3; endfunction
endpackage
package q;
  parameter int Q = p::f(7);
endpackage
module top ();
  logic [q::Q:0] z;
endmodule
