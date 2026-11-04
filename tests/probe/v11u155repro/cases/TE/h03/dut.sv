// § pkgTdStretchNonAnsiHeaderSkips155
package pk; typedef struct packed { logic a; logic b; } s_t; endpackage
module sub(i, o);
  import pk::*;
  input logic i; output logic o;
  s_t x [2];
  assign x[0] = {i, i}; assign o = x[0].a;
endmodule
module top (input logic i, output logic o);
  import pk::*;
  s_t y [2];
  sub u (i, o);
endmodule
