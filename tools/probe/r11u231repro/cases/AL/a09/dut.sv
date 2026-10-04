// § tfArgAliasDefListFollowsElab231 — a01 with CRLF line ends
package p;
  typedef enum {ARB_FIFO, ARB_WEIGHTED, ARB_RANDOM} arb_mode;
  typedef arb_mode ARB_TYPE;
  virtual class seqb;
    protected arb_mode m_arbitration = ARB_FIFO;
    extern function void set_arbitration(ARB_TYPE val);
    extern function ARB_TYPE get_arbitration();
  endclass
  function void seqb::set_arbitration(ARB_TYPE val);
    m_arbitration = val;
  endfunction
  function ARB_TYPE seqb::get_arbitration();
    return m_arbitration;
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
