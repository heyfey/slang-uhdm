// § pkgArrTdElemClone209: an array typedef of a struct holding a package enum, compared in logic
package pkg;
  typedef enum logic [1:0] { I, R, W } op_e;
  typedef struct packed { op_e op; logic [3:0] d; } a;
  typedef a [1:0] b;
endpackage
module top(input pkg::b i, output logic hit, output logic [3:0] o);
  pkg::b c;
  assign c = i;
  assign hit = (c[1].op == pkg::W);
  assign o = c[0].d;
endmodule
