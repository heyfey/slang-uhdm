// v149 arm 3 -- HOMES the implementer's grid does not carry: an INTERFACE, a
// PROGRAM, a class nested inside a module, a class nested inside a class, and
// a generate block.
interface Ifc_home;
  typedef struct {
    string ifcArgs[$];
    int    ifcTag;
  } ifc_rec_t;
  ifc_rec_t ifcRec;
  modport mp (input ifcRec);
endinterface

program Prog_home;
  typedef struct {
    string progArgs[$];
    byte   progTag;
  } prog_rec_t;
  prog_rec_t progRec;
  initial progRec.progTag = 8'd3;
endprogram

module Mod_home;
  class InnerHolder;
    typedef struct {
      string innerArgs[$];
      int    innerTag;
    } inner_rec_t;
    inner_rec_t innerRec;
    class DeeperHolder;
      typedef struct {
        string deeperArgs[$];
        int    deeperTag;
      } deeper_rec_t;
      deeper_rec_t deeperRec;
    endclass
  endclass
  if (1) begin : genLeaf
    typedef struct {
      string genArgs[$];
      int    genTag;
    } gen_rec_t;
    gen_rec_t genRec;
  end
endmodule
