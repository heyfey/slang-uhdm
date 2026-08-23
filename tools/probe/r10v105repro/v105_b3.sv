// r10v105 arm b3 — HOMES the implementer's grid never wrote: a PROGRAM, an
// INTERFACE, and a class NESTED inside another class.  Plus an out-of-body
// method whose local is declared in a NESTED BLOCK and in a for-loop header.
// MEASUREMENT ONLY.

package pn_b3;
  class dn_b3; int nx; endclass

  // a class NESTED inside another class, with an out-of-body method of the
  // OUTER class using the OUTER's parameter
  class outer_b3 #(type OT = dn_b3);
    class inner_b3;
      int iy;
    endclass
    extern function void om();
  endclass
  function void outer_b3::om();
    OT           xo_o;             // the OUTER's own parameter, out of body
    inner_b3     xo_in;            // the NESTED class, the control
  endfunction

  // an out-of-body method with a NESTED-BLOCK local and a for-loop local
  class cb_b3 #(type BT = dn_b3);
    extern function void bm();
  endclass
  function void cb_b3::bm();
    BT top_b;                      // top-level body local -> the law
    begin
      BT blk_b;                    // NESTED-BLOCK local
    end
    for (int i = 0; i < 2; i++) begin
      BT loop_b;                   // LOOP-BODY local
    end
  endfunction
endpackage

interface ifc_b3;
  class dif_b3; int fx; endclass
  class cif_b3 #(type FT = dif_b3);
    extern function void fm();
  endclass
  function void cif_b3::fm();
    FT xo_f;                       // class home is an INTERFACE
  endfunction
endinterface

program prg_b3;
  class dpr_b3; int px; endclass
  class cpr_b3 #(type PT = dpr_b3);
    extern function void pm();
  endclass
  function void cpr_b3::pm();
    PT xo_pg;                      // class home is a PROGRAM
  endfunction
  initial begin
    cpr_b3 h; h = new();
  end
endprogram

module topb3;
  import pn_b3::*;
  ifc_b3 u_if();
  outer_b3 h_o;
  cb_b3    h_b;
  initial begin h_o = new(); h_b = new(); end
endmodule
