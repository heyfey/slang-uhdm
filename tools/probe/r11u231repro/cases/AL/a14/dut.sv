// § tfArgAliasDefListFollowsElab231 — the prototype and the definition written by macros
`define PROTO(t) extern function void set_arbitration(t val);
`define DEFN(c, t) function void c::set_arbitration(t val); endfunction
package p;
  typedef enum {ARB_FIFO, ARB_WEIGHTED, ARB_RANDOM} arb_mode;
  typedef arb_mode ARB_TYPE;
  virtual class seqb;
    `PROTO(ARB_TYPE)
  endclass
  `DEFN(seqb, ARB_TYPE)
endpackage
package q;
  import p::*;
endpackage
module top;
endmodule
