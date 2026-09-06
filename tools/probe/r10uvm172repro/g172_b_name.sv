// r10uvm172 arm B — WHICH NAMES COLLAPSE.  A local variable is deliberately
// given the same spelling as a subroutine declared at each visible scope, and
// the SAME two-deep call statement is written on it.  MEASUREMENT ONLY.
package pb172;
  function int pkgfn172(); return 1; endfunction
  task pkgtk172(); endtask
endpackage

package pc172;
  function int otherpkgfn172(); return 2; endfunction
endpackage

package pd172;
  import pb172::*;

  class box172;
    string bq172[$];
    function void bm172(); endfunction
    task     bt172(); endtask
  endclass

  class user172;
    box172 hold172;
    function void clsfn172(); endfunction
    task     clstk172(); endtask

    function void probe172();
      box172 plain172;      // b01 no subroutine anywhere has this name
      box172 clsfn172;      // b02 shadows a FUNCTION of this class
      box172 clstk172;      // b03 shadows a TASK of this class
      box172 pkgfn172;      // b04 shadows a wildcard-imported package FUNCTION
      box172 pkgtk172;      // b05 shadows a wildcard-imported package TASK
      box172 bm172;         // b07 shadows a method of ANOTHER class
      plain172  = new();  plain172.bq172.push_back("b01");
      clsfn172  = new();  clsfn172.bq172.push_back("b02");
      clstk172  = new();  clstk172.bq172.push_back("b03");
      pkgfn172  = new();  pkgfn172.bq172.push_back("b04");
      pkgtk172  = new();  pkgtk172.bq172.push_back("b05");
      bm172     = new();  bm172.bq172.push_back("b07");
    endfunction

    // b06 — the receiver IS the enclosing function's return variable
    // (the MiniAmiq shape), in a class home.
    function box172 selfret172();
      selfret172 = new();
      selfret172.bq172.push_back("b06");
      return selfret172;
    endfunction
  endclass
endpackage

module topb172;
  import pd172::*;
  user172 u172;
  initial begin
    u172 = new();
    u172.probe172();
  end
endmodule
