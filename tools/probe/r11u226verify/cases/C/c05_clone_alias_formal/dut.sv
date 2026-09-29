// § cloneAliasFormalOwnChain214 — an out-of-body method of a package class with an alias-of-alias formal, cloned by an importing package
package p;
  typedef enum {A0, A1, A2} arb_e;
  typedef arb_e ARB_T;
  class seq_c;
    ARB_T m;
    extern function void set_arb(ARB_T val);
  endclass
  function void seq_c::set_arb(ARB_T val); m = val; endfunction
endpackage
package q;
  import p::*;
  class user_c extends seq_c;
    int k;
  endclass
endpackage
module top;
endmodule
