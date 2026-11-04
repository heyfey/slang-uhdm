// § pkgArrTdElemClone209: an array typedef read in a generate loop through a module port
package pkg;
  typedef struct packed { logic [3:0] x; logic y; } a;
  typedef a [3:0] b;
endpackage
module sub (input pkg::a e, output logic [3:0] o);
  assign o = e.x;
endmodule
module top (input pkg::b i, output logic [15:0] o);
  pkg::b c;
  assign c = i;
  for (genvar k = 0; k < 4; k++) begin : g
    sub s (.e(c[k]), .o(o[k*4 +: 4]));
  end
endmodule
