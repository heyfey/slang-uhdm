// § pkgArrTdElemClone209: a union element and an array typedef of an array typedef
package pkg;
  typedef union packed { logic [3:0] x; logic [3:0] z; } a;
  typedef a [1:0] b;
  typedef b [1:0] bb;
endpackage
module top (input pkg::bb i, output logic [3:0] o);
  pkg::bb c;
  assign c = i;
  assign o = c[1][0].z;
endmodule
