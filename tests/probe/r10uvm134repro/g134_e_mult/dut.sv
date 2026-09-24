// r10uvm134 grid E — 1..3 INSTANCES of the same shape, and repeats of the same
// array in one subroutine (the multiset join must not collapse them).
package qe134;
  class Cog;
    int cv[];
    int cw[int];
  endclass
  class Gear;
    Cog cogs[];
    function void thrice();
      foreach (cogs[e1]) foreach (cogs[e1].cv[e2]) $display(e2);
      foreach (cogs[e3]) foreach (cogs[e3].cv[e4]) $display(e4);
      foreach (cogs[e5]) foreach (cogs[e5].cw[e6]) $display(e6);
    endfunction
  endclass
endpackage

module me134_leaf #(parameter int W134 = 1) ();
  qe134::Cog leafs[];
  initial begin
    foreach (leafs[n1]) foreach (leafs[n1].cv[n2]) $display(W134, n2);
  end
endmodule

module me134_top;
  qe134::Cog t1[];
  qe134::Cog t2[];
  qe134::Cog t3[];
  me134_leaf #(.W134(1)) i134_one ();
  me134_leaf #(.W134(2)) i134_two ();
  me134_leaf #(.W134(3)) i134_tre ();
  initial begin
    foreach (t1[f1]) foreach (t1[f1].cv[f2]) $display(f2);
    foreach (t2[f3]) foreach (t2[f3].cw[f4]) $display(f4);
    foreach (t3[f5]) foreach (t3[f5].cv[f6]) $display(f6);
  end
endmodule
