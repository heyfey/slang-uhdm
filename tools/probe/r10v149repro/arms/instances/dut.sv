// v149 arm 7 -- 1..3 INSTANCES and a PARAMETERIZED module/class carrying the
// struct, so the ELAB view multiplies the typespec population.
package Iota_pkg;
  typedef struct {
    string instArgs[$];
    int    instTag;
  } inst_rec_t;

  class ParamHold #(int DEPTH = 3);
    typedef struct {
      string pArgs[$];
      int    pTag;
    } p_rec_t;
    p_rec_t held;
  endclass
endpackage

module Iota_cell #(parameter int SLOT = 0);
  import Iota_pkg::*;
  inst_rec_t cellRec;
  initial cellRec.instTag = SLOT;
endmodule

module instances_top;
  Iota_cell #(.SLOT(1)) i_a ();
  Iota_cell #(.SLOT(2)) i_b ();
  Iota_cell #(.SLOT(3)) i_c ();
endmodule
