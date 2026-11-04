// § pkgTdStretchNonAnsiHeaderSkips155
package pk; typedef struct packed { logic a; logic b; } s_t; endpackage
interface ifc();
  import pk::*;
  s_t x [2];
endinterface
module top;
  ifc u();
endmodule
