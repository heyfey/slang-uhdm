// § pkgQualCallQualSpan131
package p;
  function automatic int f(int x); return x + 1; endfunction
endpackage
module top (output logic [31:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    localparam int L = p::f(i);
    if (i == 0) assign o = L;
  end
endmodule
