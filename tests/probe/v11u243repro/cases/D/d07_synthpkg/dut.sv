// § clsPropLawSAliasName243
// a synthesizable module beside a package class with typedef properties (downstream control)
package p;
  typedef logic [7:0] b_t;
  class c;
    b_t m;
  endclass
  function automatic b_t inc(b_t a); return a + 1; endfunction
endpackage
module top(input p::b_t a, output p::b_t o);
  assign o = p::inc(a);
endmodule
