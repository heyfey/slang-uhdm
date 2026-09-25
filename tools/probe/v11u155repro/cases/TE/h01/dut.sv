// § pkgTdStretchNonAnsiHeaderSkips155
package pk; typedef struct packed { logic a; logic b; } s_t; endpackage
module top import pk::*; (i, o);
  input s_t i;
  output logic o;
  s_t x [2];
  assign x[0] = i; assign o = x[0].a;
endmodule
