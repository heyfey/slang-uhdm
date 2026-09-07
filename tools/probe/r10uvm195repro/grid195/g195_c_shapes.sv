// r10uvm195 arm C — the SCOPE grid and the OTHER `ref_var` producers.
// A `ref_var` reaches a subroutine's own listing through more laws than
// § builtinClassLocalUnsupportedBeforeClassPhase115; every one of them is put
// at the clone subroutine's own level here, and every non-subroutine scope
// (nested begin / named begin / fork arm / loop body / case item) is put beside
// it as the NEGATIVE — those listings are NOT the subroutine's own.
package trestle195;
  class Weir195;
  endclass
  function void nested195();
    process n_tf195;
    begin
      process n_blk195;
      string n_s195;
      n_s195 = "a";
    end
  endfunction
  function void named195();
    process m_tf195;
    nb195: begin
      process m_nb195;
      string m_s195;
      m_s195 = "b";
    end
  endfunction
  task forked195();
    process f_tf195;
    fork
      begin
        process f_arm195;
        string f_s195;
        f_s195 = "c";
      end
    join
  endtask
  function void looped195();
    process p_tf195;
    for (int i195 = 0; i195 < 2; i195++) begin
      process p_body195;
      string p_s195;
      p_s195 = "d";
    end
  endfunction
  function void cased195();
    process c_tf195;
    case (1)
      1: begin
        process c_item195;
        string c_s195;
        c_s195 = "e";
      end
    endcase
  endfunction
  // OTHER ref_var producers at the subroutine's own level
  function void statementTd195();
    typedef int st_t195;      // a typedef compiled as a STATEMENT (§155)
    st_t195 st_v195;
    string st_s195;
    st_s195 = "f";
  endfunction
  function void arrayTd195();
    typedef int at_t195[4];   // a name-based ARRAY typedef (§166)
    at_t195 at_v195;
    string at_s195;
    at_s195 = "g";
  endfunction
  function void bothKinds195();
    process b_proc195;
    process b_proc2195;
    string b_s195;
    b_s195 = "h";
  endfunction
endpackage
package gantry195;
  import trestle195::*;
  class Stile195;
    function void bobbin195();
      Weir195 g_h195;
      g_h195 = null;
    endfunction
  endclass
endpackage
