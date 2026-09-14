// a12 — A REPLICATION-VALUED PARAMETER READ WHOLE, ALONE, at the NATURAL
// width (the R4 sister of `a10`/m16).  The member is exactly 64 bits, so no
// split question arises: the only judge-visible cell is the LEFTOVER's own
// encoding.
package pk;
  localparam logic [63:0] REP = {2{32'hAB}};
  typedef struct packed { logic [63:0] r; int unsigned y; } k_t;
  function automatic k_t mk();
    k_t x; x.r = REP; x.y = 9; return x;
  endfunction
  localparam k_t K = mk();
endpackage

module kid #(
    parameter pk::k_t P = pk::K
) (output logic o);
  localparam logic [63:0] RR = P.r;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
