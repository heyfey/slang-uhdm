// r10uvm137 arm C — HOMES.  The same failing shape (a dotted loop list rooted
// at an enclosing foreach's NON-class loop variable) and its resolving twin,
// placed in every home the emitter distinguishes.  MEASUREMENT ONLY.
package mill137;

  typedef class Bale137;
  class Bale137;
    bit sacks137[Bale137];
  endclass

  class Loom137;
    bit warp137[Bale137];
    // C-in : IN-BODY class method
    function int weave137(ref bit weft137[Bale137], ref Bale137 twine137[Bale137]);
      int spin137;
      foreach (weft137[h1]) foreach (h1.sacks137[h2]) spin137++;
      foreach (twine137[h3]) foreach (h3.sacks137[h4]) spin137++;
      return spin137;
    endfunction
    // C-oob : OUT-OF-BODY class method
    extern function int card137(ref bit card_a137[Bale137], ref Bale137 card_b137[Bale137]);
    // C-st : STATIC class method
    static function int gin137(ref bit gin_a137[Bale137], ref Bale137 gin_b137[Bale137]);
      int spin137;
      foreach (gin_a137[h9]) foreach (h9.sacks137[ha]) spin137++;
      foreach (gin_b137[hb]) foreach (hb.sacks137[hc]) spin137++;
      return spin137;
    endfunction
  endclass

  function int Loom137::card137(ref bit card_a137[Bale137], ref Bale137 card_b137[Bale137]);
    int spin137;
    foreach (card_a137[h5]) foreach (h5.sacks137[h6]) spin137++;
    foreach (card_b137[h7]) foreach (h7.sacks137[h8]) spin137++;
    return spin137;
  endfunction

  // C-pf : PACKAGE FREE FUNCTION
  function automatic int scutch137(ref bit sc_a137[Bale137], ref Bale137 sc_b137[Bale137]);
    int spin137;
    foreach (sc_a137[hd]) foreach (hd.sacks137[he]) spin137++;
    foreach (sc_b137[hf]) foreach (hf.sacks137[hg]) spin137++;
    return spin137;
  endfunction

  // C-pt : PACKAGE TASK
  task automatic hackle137(ref bit hk_a137[Bale137], ref Bale137 hk_b137[Bale137]);
    int spin137;
    foreach (hk_a137[hh]) foreach (hh.sacks137[hi]) spin137++;
    foreach (hk_b137[hj]) foreach (hj.sacks137[hk]) spin137++;
  endtask

endpackage

interface ifc137;
  function automatic int ret137(ref bit if_a137[mill137::Bale137],
                                ref mill137::Bale137 if_b137[mill137::Bale137]);
    int spin137;
    foreach (if_a137[hl]) foreach (hl.sacks137[hm]) spin137++;
    foreach (if_b137[hn]) foreach (hn.sacks137[ho]) spin137++;
    return spin137;
  endfunction
endinterface

program prg137;
  bit pg_a137[mill137::Bale137];
  mill137::Bale137 pg_b137[mill137::Bale137];
  int spin137;
  initial begin
    foreach (pg_a137[hp]) foreach (hp.sacks137[hq]) spin137++;
    foreach (pg_b137[hr]) foreach (hr.sacks137[hs]) spin137++;
  end
endprogram

module topm137;
  ifc137 wire137();
  prg137 show137();
  bit md_a137[mill137::Bale137];
  mill137::Bale137 md_b137[mill137::Bale137];
  int spin137;
  // C-mi : MODULE INITIAL
  initial begin
    automatic bit li_a137[mill137::Bale137];
    automatic mill137::Bale137 li_b137[mill137::Bale137];
    foreach (li_a137[ht]) foreach (ht.sacks137[hu]) spin137++;
    foreach (li_b137[hv]) foreach (hv.sacks137[hw]) spin137++;
    // MODULE-LEVEL variables as the outer array
    foreach (md_a137[hx]) foreach (hx.sacks137[hy]) spin137++;
    foreach (md_b137[hz]) foreach (hz.sacks137[g1]) spin137++;
  end
  // C-mt : MODULE TASK
  task automatic mash137(ref bit mt_a137[mill137::Bale137],
               ref mill137::Bale137 mt_b137[mill137::Bale137]);
    foreach (mt_a137[g2]) foreach (g2.sacks137[g3]) spin137++;
    foreach (mt_b137[g4]) foreach (g4.sacks137[g5]) spin137++;
  endtask
  // C-al : ALWAYS
  always @(spin137) begin
    automatic bit al_a137[mill137::Bale137];
    foreach (al_a137[g6]) foreach (g6.sacks137[g7]) spin137++;
  end
  // C-fk : FORK ... JOIN_NONE
  initial fork
    begin
      automatic bit fk_a137[mill137::Bale137];
      foreach (fk_a137[g8]) foreach (g8.sacks137[g9]) spin137++;
    end
  join_none
endmodule
