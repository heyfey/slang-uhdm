// r10v183 arm C — the PARAMETER FENCE, both directions, plus the shape the
// fence may OVER-reach: a FUNCTION-LOCAL localparam.  Surelog's escape scans
// `component->getParamAssignVec()` (CompileType.cpp:750-762) — the COMPONENT's
// parameters, i.e. the package's.  A localparam declared inside a subroutine
// is not in that vector, so golden should still degrade it in a clone while
// slang calls it `SymbolKind::Parameter` and the fence exempts it.
package pr183_home;
  parameter int P_FIX[0:3] = '{1, 2, 3, 4};
  localparam int LP_FIX[0:2] = '{5, 6, 7};
  typedef int trio_t[0:2];
  parameter trio_t P_TRIO = '{8, 9, 10};

  int v_slots[0:3];

  function automatic int fp();
    int a = 0;
    foreach (P_FIX[i]) a += P_FIX[i];
    return a;
  endfunction

  function automatic int flp();
    int a = 0;
    foreach (LP_FIX[i]) a += LP_FIX[i];
    return a;
  endfunction

  function automatic int ft();
    int a = 0;
    foreach (P_TRIO[i]) a += P_TRIO[i];
    return a;
  endfunction

  // the NEGATIVE half of the fence — a package VARIABLE of the same shape
  function automatic int fv();
    int a = 0;
    foreach (v_slots[i]) a += v_slots[i];
    return a;
  endfunction

  // the OVER-REACH probe — a SUBROUTINE-LOCAL localparam
  function automatic int flocal();
    localparam int FL[0:2] = '{11, 12, 13};
    int a = 0;
    foreach (FL[i]) a += FL[i];
    return a;
  endfunction
endpackage

package pr183_clone;
  import pr183_home::*;
  export pr183_home::*;
  int use_pr;
  function automatic int kick_pr();
    return fp() + flp() + ft() + fv() + flocal();
  endfunction
endpackage

module pr183_top;
  import pr183_clone::*;
  int r;
  initial begin
    r = kick_pr();
  end
endmodule
