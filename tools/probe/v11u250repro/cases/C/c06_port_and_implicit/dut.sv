// § pkgArrTdBindCopies250
// an unpacked-array port of the package typedef beside an implicit net and a sub instance at depth 2
package p;
  typedef logic [3:0] a_t [2];
endpackage
module leaf(input p::a_t i, output logic [3:0] o);
  assign o = i[0] | i[1];
endmodule
module mid(input logic [3:0] x, output logic [3:0] o);
  import p::*;
  a_t v;
  assign v[0] = x;
  assign v[1] = ~x;
  assign imp = x[0];
  leaf l(.i(v), .o(o));
endmodule
module top(input logic [3:0] x, output logic [3:0] o);
  mid m(.x(x), .o(o));
endmodule
