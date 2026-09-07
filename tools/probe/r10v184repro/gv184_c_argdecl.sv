// r10v184 VERIFIER ARM C — THE ARGUMENT-DECLARATION AXIS of a built-in STRING
// method call, inside a WILDCARD-IMPORT CLONE and at HOME.
//
// The implementer's arm A varied the argument between a subroutine LOCAL, a
// FORMAL, a CLASS PROPERTY and an ENUM CONSTANT.  This arm varies the faces the
// verifier brief names and arm A does not reach:
//   * a STATIC function-level local vs an AUTOMATIC one (the brief's own axis)
//   * a BEGIN-level local, a NAMED-begin local, a NESTED bare-begin local
//   * a BEGIN-level STATIC (initialized and bare)
//   * a package PARAMETER, a package LOCALPARAM, a package-level VARIABLE
//   * an UNPACKED-ARRAY ELEMENT and a CLASS-HANDLE property (negative controls:
//     neither is a bare name reference)
//   * a for-header ITERATOR and a foreach index
//   * several name arguments in ONE call, in order
//   * the same faces inside a TASK as well as a FUNCTION
// Names, numbers and orders are deliberately unlike the corpus' and unlike
// r10uvm184repro's own arms.
package Foundry205;

  parameter  int GAUGE205 = 6;
  localparam int SPOKE205 = 2;
  int pkg_lvl205 = 3;

  class Bracket205;
    int m_reach;
    function new(); m_reach = 9; endfunction
  endclass

  function automatic string temper205(input int fml_t);
    static    int stat_lvl = 1;      // STATIC function-level local, INITIALIZED
    static    int bare_stat;         // STATIC function-level local, BARE
    automatic int auto_lvl;          // AUTOMATIC function-level local
    string        anvil;
    string        tongs;
    int           rack205[4];
    Bracket205    clip;
    bare_stat = 7;
    auto_lvl  = 2;
    anvil     = "anvilheading";
    rack205[0] = 3;
    clip = new();
    tongs = anvil.substr(1, stat_lvl);      // C1  STATIC local, initialized
    tongs = anvil.substr(1, bare_stat);     // C2  STATIC local, bare
    tongs = anvil.substr(1, auto_lvl);      // C3  AUTOMATIC local
    tongs = anvil.substr(1, GAUGE205);      // C4  package PARAMETER
    tongs = anvil.substr(1, SPOKE205);      // C5  package LOCALPARAM
    tongs = anvil.substr(1, pkg_lvl205);    // C6  package VARIABLE
    tongs = anvil.substr(1, rack205[0]);    // C7  ARRAY ELEMENT (control)
    tongs = anvil.substr(1, clip.m_reach);  // C8  CLASS-HANDLE PROPERTY (control)
    tongs = anvil.substr(fml_t, stat_lvl);  // C9  two names, formal then static
    tongs = anvil.substr(auto_lvl, bare_stat); // C10 two names, both locals
    begin : hearth205
      int        crimp;
      static int forge_stat = 4;
      crimp = 5;
      tongs = anvil.substr(1, crimp);       // C11 NAMED-begin local
      tongs = anvil.substr(1, forge_stat);  // C12 NAMED-begin STATIC
      begin
        int quench;
        quench = 6;
        tongs = anvil.substr(1, quench);    // C13 NESTED bare-begin local
      end
    end
    for (int loopv = 0; loopv < 2; loopv++)
      tongs = anvil.substr(1, loopv);       // C14 for-header ITERATOR
    foreach (rack205[ix])
      tongs = anvil.substr(1, ix);          // C15 foreach INDEX
    return tongs;
  endfunction

  task automatic scarf205(input int fml_u, output string done205);
    static int task_stat = 8;
    string     billet;
    int        swage;
    swage  = 3;
    billet = "billetstock";
    done205 = billet.substr(1, task_stat);  // C16 STATIC local in a TASK
    done205 = billet.substr(1, swage);      // C17 automatic local in a TASK
    done205 = billet.substr(1, fml_u);      // C18 FORMAL in a TASK
  endtask

  class Girder205;
    int    m_span;
    string m_label;
    extern function string weld205(input int fml_v);
  endclass

  function string Girder205::weld205(input int fml_v);
    static int cls_stat = 5;
    string     plate;
    int        rivet;
    plate = "platework";
    rivet = 2;
    weld205 = plate.substr(1, cls_stat);    // C19 STATIC local in a CLASS METHOD
    weld205 = plate.substr(1, rivet);       // C20 automatic local in a class method
    weld205 = plate.substr(1, m_span);      // C21 class property in a class method
    return weld205;
  endfunction

endpackage

// WILDCARD import — the clone path the law owns.
package Kiln205;
  import Foundry205::*;
  int seen_kiln205 = 11;
  function automatic int use_kiln205();
    Girder205 beam;
    beam = new();
    return temper205(4).len() + beam.weld205(6).len();
  endfunction
  task automatic run_kiln205(output int got205);
    string out205;
    scarf205(2, out205);
    got205 = out205.len() + use_kiln205();
  endtask
endpackage

module top205;
  import Kiln205::*;
  int tally205;
  initial begin
    run_kiln205(tally205);
    $display("%0d", tally205);
  end
endmodule
