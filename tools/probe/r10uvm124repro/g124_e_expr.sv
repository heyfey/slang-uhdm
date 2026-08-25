// r10uvm124 arm E — EXPRESSION position, the half this law must NOT touch.
// Surelog reaches it through `compileExpression`'s hier_path builder, which
// READS the subscript; `compileTfCall` (the statement arm) never does.  Every
// cell here is a control: it must read the same before and after.
package Expr124;
  class Pod;
    int  Items[$];
    function int Count(); return 2; endfunction
  endclass
  class Silo;
    Pod  Bay[$];
    Pod  Named[string];
    Pod  Lone;
    function automatic int Read(int Zx, string Wx);
      int Acc;
      Acc  = Bay[Zx].Items.size();
      Acc += Named[Wx].Items.size();
      Acc += Bay[Zx].Count();
      Acc += Lone.Items.size();
      if (Bay[Zx].Items.size() > 0) Acc++;
      $display("%0d", Named[Wx].Count());
      return Acc + Bay[0].Items.size();
    endfunction
  endclass
endpackage
