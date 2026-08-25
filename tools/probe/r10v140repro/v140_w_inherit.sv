// r10v140 arm W — INHERITANCE faces: a base class method returning an alias
// inherited by two derived classes, a virtual method overridden with the alias
// and with the base type, a pure virtual in an abstract class, and a derived
// class that re-typedefs the same name.
package Kiln_pkg;
  typedef enum bit [3:0] { KILN_COLD = 1, KILN_FIRE = 2, KILN_COOL = 4 } burnStage;
  typedef burnStage BurnStage_e;
  typedef burnStage burn_stage_alt;
  typedef struct packed { bit [4:0] cone; } glazeWord;
  typedef glazeWord GlazeWord_s;

  virtual class Vessel;
    BurnStage_e stage;
    function BurnStage_e baseAlias(); return stage; endfunction
    function burnStage baseBase(); return stage; endfunction
    pure virtual function burn_stage_alt abstractAlt();
    virtual function GlazeWord_s glazeOut(); GlazeWord_s g; return g; endfunction
  endclass

  class Bowl extends Vessel;
    virtual function burn_stage_alt abstractAlt(); return KILN_FIRE; endfunction
    virtual function GlazeWord_s glazeOut(); GlazeWord_s g; return g; endfunction
    function BurnStage_e bowlAlias(); return KILN_COOL; endfunction
  endclass

  class Urn extends Vessel;
    typedef burnStage BurnStage_e;      // re-typedef of the same NAME in a derived class
    virtual function burn_stage_alt abstractAlt(); return KILN_COLD; endfunction
    function BurnStage_e urnShadowed(); return KILN_COLD; endfunction
    function burnStage urnBase(); return KILN_FIRE; endfunction
  endclass
endpackage

module kiln_top;
  Kiln_pkg::Bowl b;
  Kiln_pkg::Urn  u;
  Kiln_pkg::BurnStage_e s;
  initial s = Kiln_pkg::KILN_COLD;
endmodule
