// § pkgArrTdElemClone209: two package array typedefs of the same struct
package pkg;
  typedef struct packed { logic [3:0] x; logic y; } a;
  typedef a [1:0] b;
  typedef a [3:0] b4;
endpackage
module top (input pkg::b i, input pkg::b4 j, output logic [3:0] o, output logic [3:0] p);
  pkg::b c;
  pkg::b4 d;
  assign c = i;
  assign d = j;
  assign o = c[1].x;
  assign p = d[3].x;
endmodule
