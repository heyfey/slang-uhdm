// § pkgArrTdElemClone209: an array typedef of a struct declared in another package
package q;
  typedef struct packed { logic [3:0] x; logic y; } a;
endpackage
package pkg;
  typedef q::a [1:0] b;
endpackage
module top (input pkg::b i, output logic [3:0] o);
  pkg::b c;
  assign c = i;
  assign o = c[1].x;
endmodule
