// § tfArgImportCloneFollowsIn231 — a direct enum typedef on an out-of-body method, the package imported by a package
package p;
  typedef enum {ARB_FIFO, ARB_WEIGHTED, ARB_RANDOM} arb_mode;
  virtual class seqb;
    protected arb_mode m_arbitration = ARB_FIFO;
    extern function void set_arbitration(arb_mode val);
  endclass
  function void seqb::set_arbitration(arb_mode val);
    m_arbitration = val;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
