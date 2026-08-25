// r10v130repro/v130_b5.sv — VERIFIER ARM b5: the HOME grid, extended.
// The SAME read face (bare size argument) written in the subroutine kinds
// uvm130's a2 did not spell: an OUT-OF-BODY TASK, an IN-BODY TASK, a MODULE
// TASK, a STATIC out-of-body method, a VIRTUAL out-of-body method, an
// out-of-body method of a DERIVED class, and an out-of-body method of a class
// NESTED in another class.  MEASUREMENT ONLY.  LHS is golden; RHS is ours.
package pkHome130v;

  class baseHome130v;
    int dynHome130v[];
    extern virtual function void virtOobAlp130v();
    extern static function void statOobBet130v();
    extern task oobTaskGam130v();
    task inBodyTaskDel130v();
      int inBodyTaskEps130v;
      inBodyTaskEps130v = 1;
      dynHome130v = new[inBodyTaskEps130v];      // h04 IN-BODY TASK -> no wire
    endtask
  endclass

  function void baseHome130v::virtOobAlp130v();
    int virtOobZet130v;
    virtOobZet130v = 2;
    dynHome130v = new[virtOobZet130v];            // h01 VIRTUAL OOB
  endfunction

  int dynStatHome130v[];
  function void baseHome130v::statOobBet130v();
    int statOobEta130v;
    statOobEta130v = 3;
    dynStatHome130v = new[statOobEta130v];        // h02 STATIC OOB
  endfunction

  task baseHome130v::oobTaskGam130v();
    int oobTaskThe130v;
    oobTaskThe130v = 4;
    dynHome130v = new[oobTaskThe130v];            // h03 OUT-OF-BODY TASK
  endtask

  class derivHome130v extends baseHome130v;
    extern function void derivOobIot130v();
  endclass
  function void derivHome130v::derivOobIot130v();
    int derivOobKap130v;
    derivOobKap130v = 5;
    dynHome130v = new[derivOobKap130v];           // h05 DERIVED-CLASS OOB
  endfunction

endpackage

import pkHome130v::*;

module topHome130v;
  int dynModHome130v[];
  // h06 a MODULE's OWN TASK
  task modTaskLam130v();
    int modTaskMuu130v;
    modTaskMuu130v = 6;
    dynModHome130v = new[modTaskMuu130v];
  endtask
  initial begin
    baseHome130v hBase130v;
    derivHome130v hDeriv130v;
    hBase130v = new();
    hDeriv130v = new();
    hBase130v.virtOobAlp130v();
    baseHome130v::statOobBet130v();
    hBase130v.oobTaskGam130v();
    hBase130v.inBodyTaskDel130v();
    hDeriv130v.derivOobIot130v();
    modTaskLam130v();
  end
endmodule
