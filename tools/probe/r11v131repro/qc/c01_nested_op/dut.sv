// § pkgQualCallQualSpan131
package p;
  function automatic int f(int x); return x * 2; endfunction
endpackage
module top (output logic [31:0] o);
  parameter int P = p::f(2) + 1;
  assign o = P;
endmodule
