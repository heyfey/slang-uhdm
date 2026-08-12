// r10svs7 ARM a3 -- the covergroup `new` in EVERY OTHER POSITION the corpus
// could put it, so the law's SCOPE is measured and not assumed.
//
// CELLS
//   E1  decl_in_class  -- construction at the class-property DECLARATION:
//                         `cgt cgh = new;`  (a NAMED covergroup TYPE handle)
//   E2  mod_var        -- a covergroup handle declared at MODULE scope with a
//                         declaration initializer  (ModuleEmit already has an
//                         arm for this: grep `ctCE.kind == SymbolKind::`
//                         `CovergroupType` in src/ModuleEmit.cpp)
//   E3  mod_initial    -- module-scope covergroup handle assigned inside an
//                         `initial` block -- a PROCEDURAL assignment outside any
//                         class, the one context that is neither E2 nor the
//                         corpus head
//   E4  this_cov       -- `this.<cg> = new();`  -- the shape
//                         § thisSuperNewAssignNoStmt3 deliberately ABSTAINS
//                         from (its comment says NewCovergroup "is deliberately
//                         NOT included").  Measured here so the abstention is a
//                         reading rather than a guess.
//   E5  dynarr         -- `q = new[4];` on a dynamic array: a DIFFERENT slang
//                         kind (NewArray) with its own arm, the MUST-ABSTAIN
//                         control
module a3;
  int gp;

  covergroup cgt;
    cpt : coverpoint gp;
  endgroup

  class decl_in_class;
    cgt cgh = new;                  // E1
  endclass

  cgt mv = new;                     // E2  module-scope declaration initializer

  cgt mi;
  initial begin
    mi = new;                       // E3  module-scope procedural assignment
  end

  class this_cov;
    int p;
    covergroup cg4;
      cp4 : coverpoint p;
    endgroup
    function new();
      this.cg4 = new();             // E4
    endfunction : new
  endclass

  class dynarr;
    int q[];
    function new();
      q = new[4];                   // E5  MUST-ABSTAIN control (NewArray)
    endfunction : new
  endclass
endmodule
