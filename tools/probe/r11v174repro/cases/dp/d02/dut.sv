// § pkgFnCastTopListing172
package q;
  localparam int W = 8;
  typedef logic [W-1:0] w_t;
  typedef struct packed { w_t a; logic [W/2-1:0] b; } s_t;
  function automatic s_t f(input logic [31:0] x);
    return s_t'(x);
  endfunction
  function automatic w_t h(input logic [31:0] x);
    automatic w_t v = w_t'(x);
    return v;
  endfunction
endpackage
package r;
  import q::*;
  function automatic w_t k(input logic [31:0] x);
    return w_t'(x);
  endfunction
endpackage
module top (input logic [31:0] a, output logic [11:0] y, output logic [7:0] z, output logic [7:0] u);
  assign y = q::f(a);
  assign z = q::h(a);
  assign u = r::k(a);
endmodule
