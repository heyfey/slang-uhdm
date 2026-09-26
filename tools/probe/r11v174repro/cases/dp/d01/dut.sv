// § pkgFnCastTopListing172
package q;
  localparam int W = 12;
  typedef logic [W-1:0] w_t;
  typedef w_t w2_t;
  typedef enum logic [2:0] {E0, E1, E2} e_t;
  function automatic w2_t f(input logic [31:0] x);
    return w2_t'(x) + w_t'(x[3:0]);
  endfunction
  function automatic e_t g(input logic [31:0] x);
    return e_t'(x[2:0]);
  endfunction
  task automatic t(input logic [31:0] x, output w_t y);
    y = w_t'(x);
  endtask
endpackage
module top (input logic [31:0] a, output logic [11:0] y, output logic [2:0] z);
  assign y = q::f(a);
  assign z = q::g(a);
endmodule
