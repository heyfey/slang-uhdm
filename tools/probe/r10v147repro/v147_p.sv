// r10uvm147 VERIFIER grid P — the POSITION axis of the corpus shape.
// The head `p.push_back(rw.value[idx][8*i+:8])` is a CALL ARGUMENT; the
// implementer's five grids only ever put the shape on the RHS of a simple
// assignment or on the LHS.  Every cell here is the SAME chain in a different
// syntactic position, on a FORMAL-ARGUMENT receiver (the kind the pristine
// gate refused) with its LOCAL-VARIABLE twin as the control.
package q147vp;
  class ip147;
    logic [63:0] value[];
    logic [63:0] fix[4];
    int          ix[8];
  endclass

  class use147;
    logic [7:0] sink;
    function void takes(logic [7:0] a); sink = a; endfunction
    function logic [7:0] ident(logic [7:0] a); return a; endfunction

    function void pos(ip147 rw, int idx, int i);
      logic [7:0]  o;
      logic [15:0] o16;
      logic [7:0]  q[$];
      takes(rw.value[idx][8*i +: 8]);                          // p01 call arg
      o = ident(rw.value[idx][8*i +: 8]);                       // p02 fn-call arg, used
      o16 = {rw.value[idx][8*i +: 8], rw.value[idx][8*i +: 8]}; // p03 concatenation
      o = 8'(rw.value[idx][8*i +: 8]);                          // p04 cast operand
      o = (i > 0) ? rw.value[idx][8*i +: 8] : 8'h0;             // p05 ternary arm
      if (rw.value[idx][8*i +: 8] == 8'h5) o = 8'h1;            // p06 comparison operand
      o16 = {2{rw.value[idx][8*i +: 4]}};                       // p07 replication element
      case (rw.value[idx][8*i +: 8])                            // p08 case expression
        8'h0: o = 8'h1;
        default: o = 8'h2;
      endcase
      q.push_back(rw.value[idx][8*i +: 8]);                     // p09 builtin-method arg
      o = |rw.value[idx][8*i +: 8];                             // p10 unary reduction
      $display("%0d", rw.value[idx][8*i +: 8]);                 // p11 system-call arg
      foreach (rw.fix[j]) rw.fix[j][8*i +: 8] = 8'h7;           // p12 foreach LVALUE
      o = rw.value[idx][8*i +: 8] + rw.value[idx][8*i +: 8];    // p13 both operands
      sink = rw.value[idx][8*i +: 8];                           // p14 property LVALUE target
    endfunction

    // the LOCAL-VARIABLE twins: the population the pristine gate already
    // accepted.  NOT ONE OF THESE MAY MOVE.
    function void posctl(int idx, int i);
      ip147 lv;
      logic [7:0]  o;
      logic [15:0] o16;
      logic [7:0]  q[$];
      takes(lv.value[idx][8*i +: 8]);                           // p21
      o16 = {lv.value[idx][8*i +: 8], lv.value[idx][8*i +: 8]}; // p22
      o = 8'(lv.value[idx][8*i +: 8]);                          // p23
      o = (i > 0) ? lv.value[idx][8*i +: 8] : 8'h0;             // p24
      q.push_back(lv.value[idx][8*i +: 8]);                     // p25
      $display("%0d", lv.value[idx][8*i +: 8]);                 // p26
      foreach (lv.fix[j]) lv.fix[j][8*i +: 8] = 8'h7;           // p27
    endfunction
  endclass

  function automatic logic [7:0] ret147(ip147 rw, int idx, int i);
    return rw.value[idx][8*i +: 8];                             // p15 RETURN expression
  endfunction
endpackage
