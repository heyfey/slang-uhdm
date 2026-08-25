// r10v143 arm K — THE FLAG-LEAK HUNT.  `inBodyClassMethod88` is a MEMBER flag
// set per subroutine and cleared only at the END of the subroutine loop, so the
// faces that could see a stale TRUE are: a free subroutine declared AFTER a
// class, a module subroutine declared AFTER a class, a NESTED class between two
// in-body methods of its outer class, a class between two module tasks, and a
// generate block after a class.  Every ungated cell here must stay BOUND.
package pkK143v;
  class Kob; int tally; int gauge; endclass
  Kob pTbl[int];

  class KouterK;
    Kob tbl[int];
    task k_before(int k = 0);              // in-body, BEFORE the nested class
      if (tbl[k].tally == 0) $display("k_before");
    endtask
    class KinnerK;
      Kob ntbl[int];
      task k_nested(int k = 0);            // in-body, in the NESTED class
        if (ntbl[k].tally == 0) $display("k_nested");
      endtask
    endclass
    task k_after(int k = 0);               // in-body, AFTER the nested class
      if (tbl[k].tally == 0) $display("k_after");
    endtask
    extern task k_oob(int k = 0);          // out-of-body twin of the same class
  endclass
  task KouterK::k_oob(int k = 0);
    if (tbl[k].tally == 0) $display("k_oob");
  endtask

  // free package subroutines declared AFTER the class: must stay BOUND
  task kfree_after(int k = 0);
    if (pTbl[k].tally == 0) $display("kfree_after");
  endtask
  function int kfree_fn_after(int k = 0);
    int r = 0;
    if (pTbl[k].tally == 0) r = 1;
    return r;
  endfunction
endpackage

module modK143v;
  import pkK143v::*;
  Kob mTbl[int];
  task kmod_before(int k = 0);             // module task BEFORE the class
    if (mTbl[k].tally == 0) $display("kmod_before");
  endtask
  class KinMod;
    Kob tbl[int];
    task kmc(int k = 0);
      if (tbl[k].tally == 0) $display("kmc");
    endtask
  endclass
  task kmod_after(int k = 0);              // module task AFTER the class
    if (mTbl[k].tally == 0) $display("kmod_after");
  endtask
  function int kmod_fn_after(int k = 0);
    int r = 0;
    if (mTbl[k].tally == 0) r = 1;
    return r;
  endfunction
  for (genvar gi = 0; gi < 2; gi++) begin : kblk
    Kob gTbl[int];
    task kgen_after(int k = 0);            // generate task AFTER the class
      if (gTbl[k].tally == 0) $display("kgen_after");
    endtask
  end
  KinMod km; KouterK ko; int n;
  initial begin
    km = new(); ko = new();
    km.kmc(); ko.k_before(); ko.k_after(); ko.k_oob();
    kmod_before(); kmod_after(); kfree_after();
    n = kmod_fn_after(); n = kfree_fn_after();
  end
endmodule
