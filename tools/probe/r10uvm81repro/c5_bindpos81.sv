// r10uvm81 arm c5 — the SECOND discriminator of
// § pkgSubRefBindsPkgVarOverFormal81: WHERE in the subroutine the reference
// sits.  Arm c4 established that a PACKAGE-scope subroutine's formal is
// displaced by a same-named package variable; BuildUVMPkg's `uvm_init` shows
// that is NOT universal — three of its four `cs` references take the package
// variable and the fourth (`if(cs == null)`, the if CONDITION at the function
// body's TOP LEVEL) keeps the io_decl.  This arm grids the position.
package p85;
  int    pv;
  int    sink;
  string ssink;

  class c85;
    int    m_a;
    string m_s;
    extern function new();
  endclass

  // The HOISTING site: an out-of-body body's begin-block local is lifted into
  // the PACKAGE's variable listing as `p85::val`.
  function c85::new();
    begin
      string val;
      val = "x";
      m_s = val;
    end
  endfunction

  function int fh85(int a); return a; endfunction

  // ---- every position at the subroutine body's TOP LEVEL ----
  function int g85(int val);
    sink = val;                                        // T1 assignment RHS
    val = 1;                                           // T2 assignment LHS
    if (val == 0) sink = 2;                            // T3 if condition
    while (val > 100) sink = 3;                        // T4 while condition
    case (val) 0: sink = 4; default: sink = 5; endcase // T5 case expression
    sink = fh85(val);                                  // T6 call argument
    for (int k = 0; k < val; k++) sink = 6;            // T7 for condition
    return val;                                        // T8 return expression
  endfunction

  // ---- the same positions one `begin` DEEP ----
  function int h85(int val);
    begin
      sink = val;                                        // B1
      val = 1;                                           // B2
      if (val == 0) sink = 2;                            // B3
      while (val > 100) sink = 3;                        // B4
      case (val) 0: sink = 4; default: sink = 5; endcase // B5
      sink = fh85(val);                                  // B6
      for (int k = 0; k < val; k++) sink = 6;            // B7
    end
    return 0;
  endfunction

  // ---- the CONTROL: the same positions with a NON-colliding formal ----
  function int k85(int free85);
    sink = free85;                                          // C1
    if (free85 == 0) sink = 2;                              // C2
    begin
      sink = free85;                                        // C3
      if (free85 == 0) sink = 2;                            // C4
    end
    return free85;                                          // C5
  endfunction

  // ---- an out-of-body TASK, both positions ----
  class d85;
    int m_b;
    extern task tv85(int val);
  endclass
  task d85::tv85(int val);
    if (val == 0) m_b = 1;                              // D1 top-level if cond
    begin
      if (val == 0) m_b = 2;                            // D2 begin if cond
      m_b = val;                                        // D3 begin assignment
    end
  endtask
endpackage

module mdl85;
  import p85::*;
  int  mv;
  logic val;                                            // MODULE object named val
  function int mg85(int val);
    mv = val;                                           // M1 module twin of T1
    if (val == 0) mv = 2;                               // M2 module twin of T3
    return val;                                         // M3
  endfunction
  initial mv = mg85(1);
endmodule
