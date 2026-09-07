// r10uvm183 grid ARM F — THE PARAMETER FENCE.
// The one shape inside a wildcard clone that golden RESOLVES: a `foreach` over
// a package PARAMETER.  `compileDatastructureTypespec` scans
// `component->getParamAssignVec()` before it falls out to the placeholder
// (CompileType.cpp:750-762) and a package's parameters exist from the first
// collect pass, so the answer is the same in every listing.  Caught first by
// the WIDE BOUNDARY on r10v178's `v178_f_shadow.sv`; this arm is the same cell
// under this pass's own name, with a localparam, an unpacked-array parameter,
// a parameter of a typedef'd array type and — as the CONTRAST — an ordinary
// package VARIABLE of the same shape, which does degrade.
package pf183;
  typedef int trio_t[3];

  parameter  int  P_ROWS  [0:3] = '{11, 22, 33, 44};
  localparam int  L_COLS  [0:2] = '{5, 6, 7};
  parameter  trio_t P_TRIO      = '{8, 9, 10};
  int             v_slots [4];          // the CONTRAST: a plain package variable

  function automatic int sum_param();
    sum_param = 0;
    foreach (P_ROWS[m1]) sum_param += P_ROWS[m1];
  endfunction

  function automatic int sum_localparam();
    sum_localparam = 0;
    foreach (L_COLS[n2]) sum_localparam += L_COLS[n2];
  endfunction

  function automatic int sum_trio();
    sum_trio = 0;
    foreach (P_TRIO[o3]) sum_trio += P_TRIO[o3];
  endfunction

  function automatic int sum_var();
    sum_var = 0;
    foreach (v_slots[p4]) sum_var += v_slots[p4];
  endfunction
endpackage

package pfwild183;
  import pf183::*;
  function automatic int roll_up();
    return sum_param() + sum_localparam() + sum_trio() + sum_var();
  endfunction
endpackage

module pf_top183;
  import pfwild183::*;
  int held183;
  initial held183 = roll_up();
endmodule
