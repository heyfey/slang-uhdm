// § pkgTdStretchNonAnsiHeaderSkips155
package pk; typedef struct packed { logic a; logic b; } s_t; endpackage
import pk::*;
module top(i, o);
  input logic i; output logic o;
  s_t x [2];
  assign x[0] = {i, i}; assign o = x[0].a;
endmodule
