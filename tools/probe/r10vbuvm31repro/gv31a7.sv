// v31a7 — the CLEAN cell-level regression probe for clause (3): a pattern whose
// DIRECT constant operands are ALL explicitly written 64 bits wide.
module v31m7;
  class v31c7;
    int     cx_all64[]  = '{64'd9, 64'd8};
    int     cx_q[$]     = '{64'd9};
    int     cx_cat[]    = {64'd9, 64'd8};
    longint cy_all64[]  = '{64'd9, 64'd8};
    byte    cz_all64[]  = '{64'd9};
    int     cx_fix[2]   = '{64'd9, 64'd8};
  endclass
  v31c7 h = new();
  initial $display(h.cx_all64.size());
endmodule
