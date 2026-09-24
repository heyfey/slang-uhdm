// § pkgQualCallQualSpan131
package p;
  function automatic int f(int x); return x + 1; endfunction
endpackage
module top (output logic [p::f(3):0] o);
  assign o = '0;
endmodule
