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
package q;
  function automatic logic [7:0] h(logic [15:0] v);
    return p::f(v) ^ p::g(v[11:0]);
  endfunction
endpackage
module dut (input logic [15:0] i, output logic [7:0] o);
  assign o = q::h(i);
endmodule
