// § constCallNameSpan137
// case cs02: a package call in a parameter's range and in a port range
package fp; function automatic int w(input int x); return x + 1; endfunction endpackage
module top #(parameter logic [fp::w(3)-1:0] P = 0) (output logic [fp::w(2)-1:0] o);
  assign o = P[2:0];
endmodule
