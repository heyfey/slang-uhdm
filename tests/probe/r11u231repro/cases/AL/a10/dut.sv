// § tfArgAliasDefListFollowsElab231 — control: the shape in $unit
typedef enum {ARB_FIFO, ARB_WEIGHTED, ARB_RANDOM} arb_mode;
typedef arb_mode ARB_TYPE;
virtual class seqb;
  extern function void set_arbitration(ARB_TYPE val);
endclass
function void seqb::set_arbitration(ARB_TYPE val);
endfunction
module top;
endmodule
