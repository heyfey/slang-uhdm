// § pkgArrTdElemClone209: an array typedef of a struct with a nested struct member
package pkg;
  typedef struct packed { logic [1:0] u; logic v; } in_t;
  typedef struct packed { in_t in; logic y; } a;
  typedef a [1:0] b;
endpackage
module top (input pkg::b i, output logic [1:0] o);
  pkg::b c;
  assign c = i;
  assign o = c[1].in.u;
endmodule
