// § boundLitWrittenDigits172 § pkgFnCastTopListing172
package p;
  typedef logic [07:00] b_t;
  typedef logic [16-1:00] w_t;
  typedef struct packed {
    logic [03:00] hi;
    logic [03:00] lo;
  } s_t;
  function automatic w_t f(logic [31:0] v);
    return w_t'(v);
  endfunction
  function automatic s_t g(logic [15:0] v);
    return s_t'(b_t'(v));
  endfunction
endpackage
module dut import p::*; (input logic [31:0] i, output w_t o, output s_t s);
  assign o = f(i);
  assign s = g(i[15:0]);
endmodule
