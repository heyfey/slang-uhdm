// r10v171 arm A — SELECT-ONLY / RECEIVER-ONLY return names in a clone.
// The patch drains `selRefs171` only inside drainFuncRet's `pf.bindVar`
// branch, and that branch is reached only after the loop head
//     if (pf.refs.empty() || !sub.returnValVar || ...) continue;
// so a clone body whose return name is touched ONLY in a select or a
// method-receiver position (never bare) is dropped before the drain.
// This arm makes that face and asks golden what it wants there.
package selonly_home_171;
  // (1) return name ONLY as a bit_select lvalue — no bare reference at all.
  function logic [7:0] so_bitonly();
    so_bitonly[0] = 1'b1;
    so_bitonly[1] = 1'b0;
    so_bitonly[7] = 1'b1;
  endfunction

  // (2) return name ONLY as a part_select lvalue.
  function logic [15:0] so_partonly();
    so_partonly[7:0]  = 8'hA5;
    so_partonly[15:8] = 8'h5A;
  endfunction

  // (3) return name ONLY as an INDEXED part_select lvalue.
  function logic [15:0] so_ipsonly();
    int qw;
    qw = 4;
    so_ipsonly[qw +: 4] = 4'h3;
    so_ipsonly[0 +: 4]  = 4'hc;
  endfunction

  // (4) return name ONLY as a METHOD RECEIVER (no bare read, no bare write).
  //     The assignment target is a local, so `refs` stays empty.
  function string so_recvonly();
    int zc;
    zc = so_recvonly.len();
    if (zc > 99) zc = 0;
  endfunction

  // (5) MIXED: one bare reference plus every select face — `refs` non-empty,
  //     so this one DOES reach the drain.  Direct comparison partner for (1).
  function logic [7:0] so_mixed();
    so_mixed = 8'h00;
    so_mixed[0] = 1'b1;
    so_mixed[3:2] = 2'b11;
  endfunction
endpackage

package selonly_clone_171;
  import selonly_home_171::*;
  function int so_use();
    logic [7:0]  u1 = so_bitonly();
    logic [15:0] u2 = so_partonly();
    logic [15:0] u3 = so_ipsonly();
    string       u4 = so_recvonly();
    logic [7:0]  u5 = so_mixed();
    return int'(u1) + int'(u2) + int'(u3) + u4.len() + int'(u5);
  endfunction
endpackage

module selonly_top_171;
  import selonly_clone_171::*;
  int so_r;
  initial so_r = so_use();
endmodule
