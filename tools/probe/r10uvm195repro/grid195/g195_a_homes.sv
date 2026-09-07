// r10uvm195 arm A — the HEAD SHAPE and its HOME/CLONE pair, in fourteen homes.
// A `process`-typed subroutine-level local: the SUBROUTINE's own vpiVariables
// entry vs the body `begin`'s entry, in the home package and in a
// wildcard-import CLONE.  MEASUREMENT ONLY.
package quarry195;
  // (1) OUT-OF-BODY class task, ANSI port list  <- the corpus head's shape
  class Chisel195;
    extern task sluice195(string weir195="");
    extern function void gantry195();
    task trestle195;
      process trestleP195;
      string trestleS195;
      trestleS195 = "a";
    endtask
    function void stile195();
      process stileP195;
      string stileS195;
      stileS195 = "b";
    endfunction
    function void ladle195();
      begin
        process ladleP195;
        string ladleS195;
        ladleS195 = "c";
      end
    endfunction
  endclass
  task Chisel195::sluice195(string weir195="");
    int sluiceI195 = 3;
    process sluiceP195;
    string sluiceS195;
    sluiceS195 = "d";
  endtask
  // (2) OUT-OF-BODY class function, no port list
  function void Chisel195::gantry195();
    process gantryP195;
    string gantryS195;
    gantryS195 = "e";
  endfunction
  // (3) package FREE function, paren header  (BLOCK production)
  function void forge195();
    process forgeP195;
    string forgeS195;
    forgeS195 = "f";
  endfunction
  // (4) package FREE function, PAREN-LESS header  (TF-ITEM production, no begin)
  function void tongs195;
    process tongsP195;
    string tongsS195;
    tongsS195 = "g";
  endfunction
  // (5) package task with a body io decl (TF-ITEM production)
  task bellows195;
    input int bellowsIn195;
    process bellowsP195;
    string bellowsS195;
    bellowsS195 = "h";
  endtask
  // (6) package task, ANSI header (BLOCK production)
  task crucible195(int crucibleIn195 = 0);
    process crucibleP195;
    string crucibleS195;
    crucibleS195 = "i";
  endtask
  // (7) a NESTED begin inside a paren function
  function void anvil195();
    int anvilI195 = 1;
    begin
      process anvilP195;
      string anvilS195;
      anvilS195 = "j";
    end
  endfunction
  // (8) a subroutine whose ONLY local is the process (no other declaration)
  function void rivet195();
    process rivetP195;
    rivetP195 = null;
  endfunction
  // (9) a subroutine with the process local and NO body statement at all
  function void press195();
    process pressP195;
  endfunction
endpackage
// ---- the WILDCARD-IMPORT CLONE of every one of the above ----
package loom195;
  import quarry195::*;
  class Bobbin195;
    function void weir195();
      Chisel195 bobbinH195;
      bobbinH195 = null;
    endfunction
  endclass
endpackage
