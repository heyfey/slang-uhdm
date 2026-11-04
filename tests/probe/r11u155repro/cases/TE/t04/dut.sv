// § pkgTdStretchNonAnsiHeaderSkips155
package pk; typedef struct packed { logic a; logic b; } s_t; endpackage
module top(input logic i);
  import pk::*;
  s_t x [2];
endmodule
