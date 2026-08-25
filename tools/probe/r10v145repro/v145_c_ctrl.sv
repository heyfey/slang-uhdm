// r10v145 arm C -- THE MUST-STAY CONTROLS.
//   § classPropNewLhsNoHoist109  -- class property initialisers
//   § oobRefVarLocalHoistNet107  -- BLOCK-ITEM production local hoist
//   § ctorBodyLocalsNotOnFunc71  -- constructor locals (paren and paren-less)
//   § tfItemLocalClassTsNotAConstructor142v
//   § qualLifetimeStubListsNoBodyLocals141 -- qualifier+lifetime stub
//   § declInitWrittenNewNoStmt66 -- a written `= new` under BOTH productions
// MEASUREMENT ONLY.
package pc145v;

  class Kc145v;
    int f;
    function new(); f = 1; endfunction
  endclass

  // ---- § 109: class property initialisers (NOT subroutine locals) ----
  class Prop145v;
    int      p1 = 5;
    Kc145v   p2 = new();
    string   p3 = "x";
    static int p4 = 9;
    function new();
      p1 = 6;
    endfunction
  endclass

  // ---- § 71 / § 142v: CONSTRUCTOR locals, paren and paren-less ----
  class Ctor145v;
    int f;
    function new();
      int cl1 = 1;
      Kc145v ck = new();
      f = cl1;
      $display(ck == null);
    endfunction
  endclass

  class Ctor2145v;
    int f;
    function new;                       // PAREN-LESS constructor
      int cl1 = 1;
      Kc145v ck = new();
      f = cl1;
      $display(ck == null);
    endfunction
  endclass

  // ---- § 141: qualifier + lifetime stub ----
  class Qual145v;
    local function automatic int q1145v(int a);
      int q = a;
      int r = a + 1;
      return q + r;
    endfunction
    protected task automatic q2145v(int a);
      int q = a;
      int r = a + 1;
      $display(q, r);
    endtask
  endclass

  // ---- § 107 shape: BLOCK-ITEM production local hoist ----
  function automatic int blk145v(int a);
    int h1 = a;
    int h2 = a + 1;
    $display(h1);
    return h1 + h2;
  endfunction

  // ---- § 66: written `= new` under BOTH productions ----
  function void new66tf145v;             // TF-ITEM
    Kc145v z1 = new();
    $display(z1 == null);
    $display(z1 != null);
  endfunction

  function void new66bi145v();           // BLOCK-ITEM
    Kc145v z1 = new();
    $display(z1 == null);
    $display(z1 != null);
  endfunction

  // ---- § 66 + ONE surviving statement, TF-ITEM (the r10uvm66 n24 shape) ----
  task new66one145v;
    input int a;
    Kc145v z2 = new();
    $display(z2 == null, a);
  endtask

endpackage
