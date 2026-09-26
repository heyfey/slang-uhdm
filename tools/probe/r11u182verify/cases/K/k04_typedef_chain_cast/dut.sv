// § pkgFnCastTopListing172
package p;
  typedef logic [6-1:0] a_t;
  typedef a_t c_t;
  typedef enum logic [2-1:0] { X0, X1, X2 } e_t;
  function automatic c_t f(logic [7:0] v);
    return c_t'(v);
  endfunction
  function automatic e_t e(logic [1:0] v);
    return e_t'(v);
  endfunction
endpackage
module dut import p::*; (input logic [7:0] i, output logic [5:0] o, output e_t q);
  assign o = f(i);
  assign q = e(i[1:0]);
endmodule
