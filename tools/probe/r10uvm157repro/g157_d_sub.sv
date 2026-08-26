// r10uvm157 grid, arm D — THE SUBROUTINE axis.  Surelog puts a subroutine-body
// typedef on the SYNTHESISED `begin` when the body has MORE THAN ONE item
// (`CompileStmt.cpp:2043-2075`) and on the `task`/`function` ITSELF when it has
// exactly one (`:2115-2121`), and drops it entirely under the TF-ITEM
// production (`compileTfPortDecl`'s `paBlock_item_declaration` arm reads only
// `paVariable_declaration`, `CompileStmt.cpp:1661-1712`).  Every one of those
// three answers gets its own cell, in a package, a module and a class.
// MEASUREMENT ONLY.
package Kiln157;
  // d1  a task whose ONLY body item IS the typedef -> the "0 or 1 Stmt" arm
  task soleTdTask157();
    typedef bit [2:0] kilnSoleTask157;
  endtask

  // d2  NOT MEASURABLE, and named here so it is never quietly re-added: a
  //     FUNCTION whose ONLY body item is a typedef SEGFAULTS Surelog
  //     (`function void f(); typedef bit [2:0] q; endfunction`, rc=139 in a
  //     package, in a module and in a class alike; the TASK spelling d1 is
  //     fine, rc=0).  Golden has NO answer for that shape, so the grid does
  //     not contain it.

  // d3  a typedef and ONE statement, no local declaration at all
  function int emberReturn157();
    typedef bit [4:0] kilnEmberRet157;
    return 1;
  endfunction

  // d4  a typedef, a local and a statement -> the synthesised wrapper
  function void emberFull157();
    typedef bit [5:0] kilnEmberFull157;
    kilnEmberFull157 fullVal;
    fullVal = 0;
  endfunction

  // d5  a typedef and a local, NO statement
  task emberDeclOnly157();
    typedef bit [6:0] kilnEmberDecl157;
    kilnEmberDecl157 declVal;
  endtask

  // d6  the body is ONE EXPLICIT begin..end holding the typedef
  function void emberBlockBody157();
    begin
      typedef bit [7:0] kilnEmberBlock157;
      kilnEmberBlock157 blockVal;
      blockVal = 0;
    end
  endfunction

  // d7  a task-scope PARAMETER alongside the typedef
  task emberParam157();
    parameter int KILN_P157 = 2;
    typedef bit [8:0] kilnEmberParam157;
    kilnEmberParam157 paramVal;
    paramVal = KILN_P157;
  endtask

  class Crucible157;
    int melt;
    extern function void pourOut157();

    // d8  an IN-BODY class method
    function void pourIn157();
      typedef bit [9:0] kilnPourIn157;
      kilnPourIn157 pourInVal;
      pourInVal = 0;
    endfunction

    // d10 a CONSTRUCTOR
    function new();
      typedef bit [11:0] kilnNewCtor157;
      kilnNewCtor157 ctorVal;
      ctorVal = 0;
      melt = 0;
    endfunction

    // d11 a VIRTUAL method
    virtual function void pourVirtual157();
      typedef bit [12:0] kilnPourVirt157;
      kilnPourVirt157 virtVal;
      virtVal = 0;
    endfunction

    // d12 a STATIC method
    static function void pourStatic157();
      typedef bit [13:0] kilnPourStatic157;
      kilnPourStatic157 statVal;
      statVal = 0;
    endfunction
  endclass

  // d13 an OUT-OF-BODY class method
  function void Crucible157::pourOut157();
    typedef bit [14:0] kilnPourOut157;
    kilnPourOut157 pourOutVal;
    pourOutVal = 0;
  endfunction
endpackage

module Forge157;
  int glow;

  // d14 a module task under the TF-ITEM production (a NON-ANSI port
  //     declaration inside the body opens `compileTfPortDecl`, which never
  //     compiles a `paType_declaration` at all)
  task tfItemTask157;
    input int spark;
    typedef bit [15:0] forgeTfItem157;
    forgeTfItem157 tfItemVal;
    tfItemVal = spark[15:0];
  endtask

  // d15 the SAME shape with an ANSI port list -> the BLOCK-ITEM production
  task ansiTask157(input int spark);
    typedef bit [16:0] forgeAnsi157;
    forgeAnsi157 ansiVal;
    ansiVal = spark[16:0];
  endtask

  // d16 an AUTOMATIC function
  function automatic void autoFn157();
    typedef bit [17:0] forgeAuto157;
    forgeAuto157 autoVal;
    autoVal = 0;
  endfunction

  // d17 a module task whose only item is the typedef
  task soleTdModTask157();
    typedef bit [18:0] forgeSoleMod157;
  endtask

  initial begin
    tfItemTask157(1);
    ansiTask157(2);
    autoFn157();
    soleTdModTask157();
    Kiln157::soleTdTask157();
    glow = Kiln157::emberReturn157();
    Kiln157::emberFull157();
    Kiln157::emberDeclOnly157();
    Kiln157::emberBlockBody157();
    Kiln157::emberParam157();
  end
endmodule
