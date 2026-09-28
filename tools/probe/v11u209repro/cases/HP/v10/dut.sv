// § pkgArrTdElemClone209: an array typedef of a struct used through a wildcard import in two modules
package pkg;
  typedef struct packed { logic [1:0] x; logic y; } a;
  typedef a [2:0] b;
endpackage
module sub import pkg::*; (input b i, output logic [1:0] o);
  assign o = i[2].x;
endmodule
module top import pkg::*; (input b i, output logic [1:0] o, output logic y);
  b c;
  assign c = i;
  assign y = c[1].y;
  sub s (.i(c), .o(o));
endmodule
