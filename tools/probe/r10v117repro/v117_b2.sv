// r10v117 (verifier) arm b2 — THE HOME GRID r10uvm117's a2 DID NOT COVER.
// a2 has six homes (free pkg fn, free pkg task, oob method, in-body method,
// module fn, $unit fn).  This arm adds the homes a2 leaves out, each with its
// OWN name and its own line:
//   a STATIC in-body class method, a STATIC out-of-body class method,
//   a MODULE's own TASK (a2 only has a module FUNCTION),
//   an INTERFACE's own function, a PROGRAM's own function,
//   a class declared INSIDE A MODULE with an out-of-body method
//     (classBodyHomePkg75 is null there -- the § 75 home walk requires a
//      PACKAGE parent scope),
//   a package function reached through PACKAGE SCOPE with NO import,
//   and a NESTED begin/end block inside a free package TASK.
package Qkv2;

  class Kv2cls;
    static function void statInBodyFnV2();
      process statInBodyM6;                  // STATIC IN-BODY method local
      statInBodyM6 = process::self();
    endfunction
    extern static function void statOobFnV2();
  endclass

  function void Kv2cls::statOobFnV2();
    process statOobR4;                       // STATIC OUT-OF-BODY method local
    statOobR4 = process::self();
  endfunction

  task automatic freeTaskBlockV2();
    begin : innerBlkV2
      process blkNestedJ3;                   // BLOCK ITEM inside a free TASK
      blkNestedJ3 = process::self();
    end
  endtask

  function automatic void scopeOnlyFnV2();
    process scopeOnlyX9;                     // reached WITHOUT any import
    scopeOnlyX9 = process::self();
  endfunction

endpackage

interface IfaceKv2;
  function automatic void ifaceFnV2();
    process ifaceOwnG3;                      // an INTERFACE's own function
    ifaceOwnG3 = process::self();
  endfunction
endinterface

program ProgKv2;
  function automatic void progFnV2();
    process progOwnP1;                       // a PROGRAM's own function
    progOwnP1 = process::self();
  endfunction
  initial progFnV2();
endprogram

import Qkv2::*;
module TopBeeTwo;
  // a class declared inside a MODULE, with an OUT-OF-BODY method: § 75's home
  // walk wants a PACKAGE parent scope and finds a module here.
  class ModClsV2;
    extern function void modOobFnV2();
  endclass
  function void ModClsV2::modOobFnV2();
    process modOobT7;                        // OOB method of a MODULE class
    modOobT7 = process::self();
  endfunction

  // a MODULE's own TASK (a2 only measured a module FUNCTION)
  task automatic modOwnTaskV2();
    process modTaskS5;
    modTaskS5 = process::self();
  endtask

  ModClsV2 mh2;
  initial begin
    Kv2cls::statInBodyFnV2();
    Kv2cls::statOobFnV2();
    freeTaskBlockV2();
    Qkv2::scopeOnlyFnV2();
    mh2 = new();
    mh2.modOobFnV2();
    modOwnTaskV2();
  end
endmodule
