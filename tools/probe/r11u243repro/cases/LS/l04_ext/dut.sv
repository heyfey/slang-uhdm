// § clsPropLawSAliasName243
// a derived class's property and an out-of-body method local of the same typedef
package p;
  typedef int i_t;
  class base; i_t bv; endclass
  class der extends base;
    i_t dv;
    extern function i_t sum();
  endclass
  function i_t der::sum();
    i_t s;
    s = bv + dv;
    return s;
  endfunction
endpackage
module top;
  import p::*;
  der d;
endmodule
