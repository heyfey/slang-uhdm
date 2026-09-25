// § pkgTdStretchNonAnsiHeaderSkips155
package pk; typedef struct packed { logic a; logic b; } s_t; endpackage
module top(i, o);
  import pk::*;
  input logic i; output logic o;
  s_t x;
  assign x = {i, i}; assign o = x.a;
endmodule
