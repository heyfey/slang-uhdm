// VERIFIER probe: shapes the r10earl37 grid does NOT contain.
//  vg3  : gen-scope port actual with a GENVAR-SELECTED BASE and THREE+ parts
//         (`darr_i[b].mid.inner.rd`) -> the ONE shape where the ScopedName arm
//         sets genVarBaseEmitted and writes the RAW dotted leaf fullname, which
//         the pass's POST-STAMP now overwrites unconditionally.  No grid cell
//         has it (f_mparr/f_selint are 2-part, so baseSelSyn wins and the flag
//         is never set).
//  vg2  : the 2-part control on the same array.
//  vpk  : a ScopedName carrying BOTH `::` AND `.` (`q39::CFG.rd`) -> the gate's
//         dot conjunct ADMITS it; is that golden's answer?
//  vpa3 : a PLAIN-BODY MODULE ARRAY with a 3-part dotted actual (CALL SITE 2).
package q39;
  typedef struct packed { logic rd; logic [7:0] addr; } req_t;
  typedef struct packed { logic en; req_t inner; } mid_t;
  typedef struct packed { logic top; mid_t mid; } deep_t;
  localparam req_t CFG = '{rd: 1'b1, addr: 8'h5};
endpackage

module ch39 (
  input  logic       rd_i,
  input  logic [7:0] addr_i,
  output logic       ack_o
);
  assign ack_o = rd_i & addr_i[0];
endmodule

module top39 (
  input  q39::deep_t  darr_i [0:1],
  input  q39::deep_t  dp_i,
  output logic [31:0] ack_o
);
  for (genvar b = 0; b < 2; b++) begin : gen_v
    // vg3 — GENVAR-SELECTED BASE, FOUR parts
    ch39 i_vg3 (
      .rd_i(darr_i[b].mid.inner.rd),
      .addr_i(darr_i[b].mid.inner.addr),
      .ack_o(ack_o[b])
    );
    // vg2 — the 2-part control on the same array
    ch39 i_vg2 (
      .rd_i(darr_i[b].top),
      .addr_i(dp_i.mid.inner.addr),
      .ack_o(ack_o[2+b])
    );
    // vpk — `::` AND `.` in one actual
    ch39 i_vpk (
      .rd_i(q39::CFG.rd),
      .addr_i(q39::CFG.addr),
      .ack_o(ack_o[4+b])
    );
  end
  // vpa3 — PLAIN-BODY MODULE ARRAY, 3-part dotted actual (CALL SITE 2)
  ch39 i_vpa3 [0:1] (
    .rd_i(dp_i.mid.inner.rd),
    .addr_i(dp_i.mid.inner.addr),
    .ack_o(ack_o[8 +: 2])
  );
endmodule
