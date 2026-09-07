// r10v192 ARM E — NON-PACKAGE CALLER SCOPES (module / interface / program /
// class in a module) and IN-BODY vs EXTERN, both views.  MEASUREMENT ONLY.
package scopeP;
  class Node;
    static function int idInBody();
      return 6;
    endfunction
    extern static function int id();
    extern static function int nodeCaller();
  endclass
  function int Node::id();
    return 8;
  endfunction
  function int Node::nodeCaller();
    return Node::id() + Node::idInBody();
  endfunction
endpackage

program scopeProg;
  import scopeP::*;
  int x;
  initial x = Node::id();
endprogram

interface scopeIf;
  import scopeP::*;
  function automatic int ifCaller();
    return Node::id();
  endfunction
endinterface

module scopeMod;
  import scopeP::*;
  // a class DECLARED IN A MODULE with an out-of-body method: the listing is
  // the module's, never a package's, so the law can never reach it.
  class Local;
    extern static function int loc();
    extern static function int locCaller();
  endclass
  function int Local::loc();
    return 12;
  endfunction
  function int Local::locCaller();
    return Local::loc() + Node::id();
  endfunction
  int y;
  initial y = Local::locCaller();
endmodule

module v192e_top;
  scopeMod u_m();
  scopeIf u_if();
  int z;
  initial z = u_if.ifCaller();
endmodule
