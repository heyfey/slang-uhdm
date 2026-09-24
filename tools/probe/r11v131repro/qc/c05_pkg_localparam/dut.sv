// § pkgQualCallQualSpan131
package p;
  function automatic int f(int x); return x + 1; endfunction
endpackage
package q;
  localparam int L = p::f(4);
endpackage
module top (output logic [31:0] o);
  assign o = q::L;
endmodule
