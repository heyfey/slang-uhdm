// r10sd9 GRID CELL g4 — NEGATIVE CONTROL: a class-nested typedef declared in a
// BASE class.  § classScopedTypedefPropIsBareLogicVar73 / classAssocElemVar
// degrade these to a BARE logic_var on purpose (Surelog cannot see a base
// class's datatype map), and the on-demand typedef build this pass adds must
// NOT resurrect them.
package pw;
  class kw;
    int xw;
  endclass
  class basew;
    typedef kw tw;
  endclass
  class derw extends basew;
    tw a_inherited [string];
    tw s_inherited;
  endclass
endpackage
module topw;
  pw::derw hw;
endmodule
