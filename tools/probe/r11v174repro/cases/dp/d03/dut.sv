// § pkgFnCastTopListing172
package q;
  typedef logic [7:0] b_t;
  typedef bit signed [15:0] sw_t;
  class c;
    function b_t m(input int x); return b_t'(x); endfunction
  endclass
  function automatic sw_t f(input int x); return sw_t'(x); endfunction
  function automatic int g(input int x); return int'(b_t'(x)) + $bits(b_t); endfunction
endpackage
module top (input int a, output logic [15:0] y, output int z);
  assign y = q::f(a);
  assign z = q::g(a);
endmodule
