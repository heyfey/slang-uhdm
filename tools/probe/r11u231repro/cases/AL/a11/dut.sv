// § tfArgAliasDefListFollowsElab231 — the alias names another package's enum
package p0;
  typedef enum {ARB_FIFO, ARB_WEIGHTED, ARB_RANDOM} arb_mode;
endpackage
package p;
  typedef p0::arb_mode ARB_TYPE;
  virtual class seqb;
    extern function void set_arbitration(ARB_TYPE val);
  endclass
  function void seqb::set_arbitration(ARB_TYPE val);
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
