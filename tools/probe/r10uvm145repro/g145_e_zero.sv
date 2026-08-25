// r10uvm145 arm E — THE ZERO-STATEMENT TF-ITEM BODIES, quarantined.
// A paren-less subroutine whose body is NOTHING BUT initialised declarations
// SEGFAULTS the PRISTINE binary (rc=139): with `bodyTfItems9` set, the wrapper
// begin's anchor loop skips every VariableDeclaration, so `items9` is EMPTY and
// `items9[0]` reads off the end of the vector — while `eff9 = initCount +
// real.size()` had already decided to build that wrapper.  These cells
// therefore cannot share an arm with scoreable ones (the arm would print
// NO-pris and score nothing), and they are this pass's POSITIVE CONTROL: the
// law removes the reason the wrapper was built at all.
// MEASUREMENT ONLY.
package pe145;
  function void zeroTwoNoParen145;      // TF-ITEM, 2 inits, 0 statements
    int k1 = 4;
    int k2 = 5;
  endfunction
  function void zeroThreeNoParen145;    // TF-ITEM, 3 declarators, 0 statements
    int w1 = 6, w2 = 7, w3 = 8;
  endfunction
  function void zeroTwoParen145();      // BLOCK-ITEM twin (does NOT crash)
    int k1 = 4;
    int k2 = 5;
  endfunction
  task zeroTaskIo145;                   // TF-ITEM task, 2 inits, 0 statements
    input int gg;
    int t1 = 1;
    int t2 = 2;
  endtask
  task zeroTaskNoIo145;                 // BLOCK-ITEM twin
    int t1 = 1;
    int t2 = 2;
  endtask
endpackage
