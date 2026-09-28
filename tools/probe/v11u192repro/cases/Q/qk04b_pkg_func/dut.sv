// § pkgQualBoundSpanQualifier192
package p;
  parameter int unsigned S = $clog2(16);
endpackage
package q;
  function automatic logic [31:0] f(logic [31:0] v); return v[p::S:0]; endfunction
endpackage
module top (input logic [31:0] x, output logic [31:0] z);
  assign z = q::f(x);
endmodule
