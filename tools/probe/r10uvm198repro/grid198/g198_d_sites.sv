// r10uvm198 arm D — WHICH DECLARATION SITE.
// The corpus head is a local of a `begin` inside a `foreach`; this arm puts the
// same class-scope typedef at every other site an emitter has a separate arm
// for, so a law written at two sites can be shown to need exactly those two.
package weir198;
  class Sluice198;
    typedef struct { int gate198; string pen198; } gateSt198;
    extern task drain198();
  endclass
  task Sluice198::drain198();
    gateSt198 dTf198;                       // TF-ITEM (no begin)
    gateSt198 dInit198 = dTf198;            // TF-ITEM WITH INITIALISER
    gateSt198 dArr198[4];                   // TF-ITEM ARRAY of the typedef
    int i198;
    begin : named198
      gateSt198 dNamed198;                  // NAMED begin
      dNamed198.gate198 = 0;
    end
    for (i198 = 0; i198 < 2; i198++) begin
      gateSt198 dLoop198;                   // LOOP body
      dLoop198.gate198 = i198;
    end
    if (i198 == 0) begin
      gateSt198 dIf198;                     // IF arm
      dIf198.gate198 = 1;
    end
    case (i198)
      0: begin
        gateSt198 dCase198;                 // CASE item
        dCase198.gate198 = 2;
      end
      default: ;
    endcase
    fork
      begin
        gateSt198 dFork198;                 // FORK arm
        dFork198.gate198 = 3;
      end
    join_none
    dTf198.gate198 = 0;
    dArr198[0].gate198 = 0;
  endtask
endpackage
package mill198;
  import weir198::*;
  class Mill198;
    function void grind198();
      Sluice198 s198;
      s198 = null;
    endfunction
  endclass
endpackage
