// r10uvm143 arm C — THE INDEX-SHAPE and DIRECTION axes, all inside an IN-BODY
// class method (where § hpIdxClassBodyNeverLateBinds143 says golden binds
// NOTHING) and the matching OUT-OF-BODY twin (where it binds everything the
// eager binder can reach).  Deliberately dissimilar names, mixed case, mixed
// arities.
package Kiln_pkg;

  parameter int GLAZE = 3;

  class Shard;
    int Depth;
    int flake;
  endclass

  class Tray;
    Shard crocks[Shard];
    Shard slots[int];
    int   plainQ[int];
    Shard prop;
    int   member;

    function int helper(int q); return q + 1; endfunction

    // --- index shapes, IN BODY
    task cLiteral();                 if (slots[7].Depth == 0)              $display("c1"); endtask
    task cParam();                   if (slots[GLAZE].Depth == 0)          $display("c2"); endtask
    task cProperty();                if (slots[member].Depth == 0)         $display("c3"); endtask
    task cFormal(int Bay);           if (slots[Bay].Depth == 0)            $display("c4"); endtask
    task cFormalDef(int Bay = 9);    if (slots[Bay].Depth == 0)            $display("c5"); endtask
    task cOutDir(output int Bay);    Bay = 1; if (slots[Bay].Depth == 0)   $display("c6"); endtask
    task cInoutDir(inout int Bay);   if (slots[Bay].Depth == 0)            $display("c7"); endtask
    task cRefDir(ref int Bay);       if (slots[Bay].Depth == 0)            $display("c8"); endtask
    task cExprIdx(int Bay = 2);      if (slots[Bay + 1].Depth == 0)        $display("c9"); endtask
    task cCallIdx(int Bay = 2);      if (slots[helper(Bay)].Depth == 0)    $display("c10"); endtask
    task cNestedSel(int Bay = 2);    if (slots[plainQ[Bay]].Depth == 0)    $display("c11"); endtask
    task cClassKey(Shard Lot = null);if (crocks[Lot].Depth == 0)             $display("c12"); endtask
    task cThreeUses(int Bay = 4);
      if (slots[Bay].Depth == 0) $display("c13a");
      if (slots[Bay].flake == 1) $display("c13b");
      if (slots[Bay].Depth == 2) $display("c13c");
    endtask
  endclass

  // --- the OUT-OF-BODY twin of the same shapes
  class Cart;
    Shard crocks[Shard];
    Shard slots[int];
    int   plainQ[int];
    int   member;
    function int helper(int q); return q + 1; endfunction
    extern task dFormalDef(int Bay = 9);
    extern task dExprIdx(int Bay = 2);
    extern task dCallIdx(int Bay = 2);
    extern task dNestedSel(int Bay = 2);
    extern task dClassKey(Shard Lot = null);
    extern task dProperty();
  endclass

  task Cart::dFormalDef(int Bay = 9); if (slots[Bay].Depth == 0)         $display("d5");  endtask
  task Cart::dExprIdx(int Bay = 2);   if (slots[Bay + 1].Depth == 0)     $display("d9");  endtask
  task Cart::dCallIdx(int Bay = 2);   if (slots[helper(Bay)].Depth == 0) $display("d10"); endtask
  task Cart::dNestedSel(int Bay = 2); if (slots[plainQ[Bay]].Depth == 0) $display("d11"); endtask
  task Cart::dClassKey(Shard Lot = null); if (crocks[Lot].Depth == 0)      $display("d12"); endtask
  task Cart::dProperty();             if (slots[member].Depth == 0)      $display("d3");  endtask

endpackage

module kilnTop;
  Kiln_pkg::Tray tray;
  Kiln_pkg::Cart cart;
  int spare;
  initial begin
    tray = new(); cart = new();
    tray.cLiteral(); tray.cOutDir(spare); tray.cInoutDir(spare); tray.cRefDir(spare);
    cart.dFormalDef();
  end
endmodule
