// § pkgTdStretchNonAnsiHeaderSkips155
package pk; typedef struct packed { logic [1:0] a; } s_t; endpackage
module sub(o);
  import pk::*;
  output logic o;
  s_t y [3];
  assign o = y[0].a[0];
endmodule
module top(output logic o); sub u(o); endmodule
