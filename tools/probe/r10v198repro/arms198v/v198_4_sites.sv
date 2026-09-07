// r10v198 arm 4 — SITES AND FACES the two patched sites sit next to: the
// RETURN type, the FORMALS (§ 36's cells, which must be unchanged), a STATIC
// local, an AUTOMATIC local, an INITIALISED local, an ARRAY (this pass's stated
// fence), a foreach body (the corpus head's own shape), a for body, a while
// body, a case item, an if arm, a fork arm and a named begin.
package quarryV4;
  typedef struct { int pqA; } pkgStV4;
  class KilnV4;
    typedef struct { int fireAV4; string fireBV4; } clsStV4;
    typedef int clsIntV4;
    extern function clsStV4 bakeV4(clsStV4 doughV4, clsIntV4 heatV4);
    extern task        soakV4(clsIntV4 nV4);
  endclass
  function KilnV4::clsStV4 KilnV4::bakeV4(clsStV4 doughV4, clsIntV4 heatV4);
    static    clsStV4 stV4;                    // STATIC local
    automatic clsStV4 auV4;                    // AUTOMATIC local
    clsStV4 initV4 = doughV4;                  // INITIALISED local
    clsStV4 arrV4 [3];                         // ARRAY — the stated fence
    clsIntV4 idxV4;
    pkgStV4  ctlV4;                            // CONTROL: package struct
    begin : namedV4
      clsStV4 nbV4;
      nbV4.fireAV4 = heatV4;
    end
    for (int iV4 = 0; iV4 < 2; iV4++) begin
      clsStV4 forV4;
      forV4.fireAV4 = iV4;
    end
    while (idxV4 < 1) begin
      clsStV4 whV4;
      whV4.fireAV4 = 0;
      idxV4++;
    end
    case (heatV4)
      0: begin
        clsStV4 csV4;
        csV4.fireAV4 = 0;
      end
      default: begin
        clsStV4 dfV4;
        dfV4.fireAV4 = 1;
      end
    endcase
    if (heatV4 > 0) begin
      clsStV4 ifV4;
      ifV4.fireAV4 = 2;
    end
    else begin
      clsStV4 elV4;
      elV4.fireAV4 = 3;
    end
    stV4.fireAV4 = 0; auV4.fireAV4 = 0; initV4.fireAV4 = 0;
    arrV4[0].fireAV4 = 0; ctlV4.pqA = 0;
    return doughV4;
  endfunction
  task KilnV4::soakV4(clsIntV4 nV4);
    clsIntV4 valsV4 [2];
    fork
      begin
        clsStV4 fkV4;
        fkV4.fireAV4 = 0;
      end
    join_none
    foreach (valsV4[iV4]) begin
      clsStV4 feV4;                            // the CORPUS HEAD's own shape
      feV4.fireAV4 = valsV4[iV4];
    end
  endtask
endpackage
package sluiceV4;
  import quarryV4::*;
  class TrayV4;
    function void holdV4();
      KilnV4 kV4;
      kV4 = null;
    endfunction
  endclass
endpackage
