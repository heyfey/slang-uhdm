// r10v151 (VERIFIER) arm 5 — CONTAINERS the implementer's arm E does not
// reach, and the CHAINING / ARGUMENT / MULTI-SITE spellings the brief names.
// MEASUREMENT ONLY.  LHS is always golden (Surelog), RHS always ours.
package Cpk5;
  class Node5;
    int ofs;
  endclass
  class Runner5;
    int   vq[$];
    Node5 nq[$];
    bit   bq[$];
    function int sz5(); return vq.size(); endfunction
    task drive5;
      int  a;
      int  b;
      a = 0;
      do begin
        vq.sort() with ( item );                 // do..while body
      end while (a > 0);
      foreach (vq[i2]) begin
        nq.sort() with ( item.ofs );             // foreach body
      end
      fork
        begin vq.rsort() with ( item ); end      // fork..join_any arm
        begin bq.and(); end
      join_any
      case (a) inside
        [0:3]: vq.sort() with ( item );          // case-inside arm
        default: bq.xor();
      endcase
      if (a == 0) begin : lbl5
        vq.unique();                             // labelled begin
      end : lbl5
      while (a < 0) vq.shuffle();
      // ---- the SAME cell written THREE TIMES in a row (multi-instance) ----
      vq.sort() with ( item );
      vq.sort() with ( item );
      vq.sort() with ( item );
      // ---- CALL ARGUMENT / CONDITION / CHAINED positions ----
      b = vq.sum() with ( item );
      $display("%0d", vq.sum() with ( item ));
      if ((vq.sum() with ( item )) > 0) a = 1;
      b = sz5();
      vq.sort() with ( item );
      b = vq.size();                             // the chained read, split
      b = vq[0];
      a = b;
    endtask
    function void fn5();
      vq.sort() with ( item );                   // inside a FUNCTION
      bq.or();
    endfunction
  endclass
endpackage
module Cmod5;
  int mq5[$];
  bit mb5[$];
  always_comb begin
    mq5.sort() with ( item );
  end
  initial begin
    mb5.and();
    #1 mq5.rsort() with ( item );                // after a delay control
  end
  final begin
    mq5.unique();
  end
endmodule
