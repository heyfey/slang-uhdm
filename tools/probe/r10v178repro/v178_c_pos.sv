// r10v178 VERIFIER ARM C — REFERENCE POSITION x CLONE.  MEASUREMENT ONLY.
// Positions the implementer's arm B does not walk, all in the SAME home
// package so one clone carries every one of them:
//   if-condition / while-condition / case selector / case ITEM /
//   ternary condition / ternary arm / array index / concatenation operand /
//   for-loop bound / local variable INITIALISER / user-call argument /
//   $system-call argument / return of a user call / return of a sys call /
//   return of a binary op / bare return / assignment Rhs / twice in ONE body.

package Rho_home_V;
  parameter int PV = 6;
  parameter int QV = 3;

  function automatic int p_cond(input int a);
    int r; r = a; if (a > PV) r = r + 1; return r;
  endfunction
  function automatic int p_while(input int a);
    int r; r = 0; while (r < PV) r = r + a; return r;
  endfunction
  function automatic int p_casesel(input int a);
    int r; r = 0; case (PV) 6: r = a; default: r = 0; endcase return r;
  endfunction
  function automatic int p_caseitem(input int a);
    int r; r = 0; case (a) PV: r = 1; default: r = 2; endcase return r;
  endfunction
  function automatic int p_terncond(input int a);
    return (PV > 2) ? a : 0;
  endfunction
  function automatic int p_ternarm(input int a);
    return (a > 2) ? PV : 0;
  endfunction
  function automatic int p_index(input int a);
    int arr [0:15]; arr[PV] = a; return arr[PV];
  endfunction
  function automatic int p_concat(input int a);
    return {a[15:0], PV[15:0]};
  endfunction
  function automatic int p_forbound(input int a);
    int r; r = 0; for (int i = 0; i < PV; i++) r = r + a; return r;
  endfunction
  function automatic int p_varinit(input int a);
    int r = PV; return r + a;
  endfunction
  function automatic int p_callee(input int a); return a + 1; endfunction
  function automatic int p_callarg(input int a);
    return p_callee(PV) + a;
  endfunction
  function automatic int p_sysarg(input int a);
    return $clog2(PV) + a;
  endfunction
  function automatic int p_retcall(input int a);
    return p_callee(PV);
  endfunction
  function automatic int p_retsys(input int a);
    return $clog2(PV);
  endfunction
  function automatic int p_retbin(input int a);
    return a + PV;
  endfunction
  function automatic int p_retbare(input int a);
    return PV;
  endfunction
  function automatic int p_asgn(input int a);
    int r; r = PV; return r + a;
  endfunction
  function automatic int p_twice(input int a);
    int r; r = a; r ^= PV; r = r + PV; return r;    // SAME param TWICE
  endfunction
  function automatic int p_twoparams(input int a);
    int r; r = a; r ^= PV; r = r + QV; return r;    // two different params
  endfunction
endpackage

package Sigma_imp_V;
  import Rho_home_V::*;
endpackage

module m_v178c (input logic ck, output int y);
  import Rho_home_V::*;
  import Sigma_imp_V::*;
  assign y = p_cond(1) + p_while(2) + p_casesel(3) + p_caseitem(4)
           + p_terncond(5) + p_ternarm(6) + p_index(7) + p_concat(8)
           + p_forbound(9) + p_varinit(10) + p_callarg(11) + p_sysarg(12)
           + p_retcall(13) + p_retsys(14) + p_retbin(15) + p_retbare(16)
           + p_asgn(17) + p_twice(18) + p_twoparams(19);
endmodule
