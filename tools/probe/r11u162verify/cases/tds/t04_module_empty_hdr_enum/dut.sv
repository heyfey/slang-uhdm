// § pkgTdStretchNonAnsiHeaderSkips155
package pk; typedef enum logic [1:0] { A, B, C } e_t; endpackage
module top();
  import pk::*;
  e_t x [2];
endmodule
