// § pkgFnCastTopListing172
package p;
  typedef logic [8-1:0] b_t;
  typedef struct packed {
    logic [4-1:0] hi;
    logic [4-1:0] lo;
  } s_t;
  function automatic b_t f(logic [15:0] v);
    return b_t'(v);
  endfunction
  function automatic s_t g(logic [11:0] v);
    return s_t'(v);
  endfunction
endpackage
module dut (input logic [15:0] i, output logic [7:0] o, output p::s_t s);
  localparam p::b_t K = p::f(16'h1234);
  assign o = p::f(i) ^ K;
  assign s = p::g(i[11:0]);
endmodule
