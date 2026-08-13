// r10earl37 GRID a1 — struct-MEMBER-SELECT as a PORT ACTUAL.
// Reproduces Earlgrey flash_phy.sv:129 `.rd_i(flash_ctrl_i.rd)` — a bare
// member select of a PACKED-STRUCT INPUT PORT, connected by NAME, inside a
// genvar generate block.  Every cell differs from the witness in exactly one
// property so the golden's answer names the axis.
//
// The axes crossed here:
//   base KIND      : enclosing module's INPUT PORT / a module-local VAR / net
//   position       : inside a genvar generate block / plain module body
//   conn form      : named (.f(a.m)) / positional
//   actual shape   : bare member / nested member / member+part-select /
//                    member inside an operation / whole port (control)
//   member type    : 1-bit logic / a vector / a nested struct
package q37;
  typedef struct packed {
    logic       req;
    logic       rd;
    logic [7:0] addr;
  } req_t;
  typedef struct packed {
    logic       en;
    req_t       inner;
  } outer_t;
endpackage

module ch37 (
  input  logic       rd_i,
  input  logic [7:0] addr_i,
  output logic       ack_o
);
  assign ack_o = rd_i & addr_i[0];
endmodule

module ch37w (
  input  q37::req_t all_i,
  output logic      ack_o
);
  assign ack_o = all_i.rd;
endmodule

module top37 import q37::*; (
  input  q37::req_t   pin_i,
  input  q37::outer_t onest_i,
  output logic [15:0] ack_o
);

  q37::req_t   locv;
  q37::outer_t lonest;
  assign locv   = pin_i;
  assign lonest = onest_i;

  // ---- g_* : INSIDE a genvar generate block (the witness's own position)
  for (genvar b = 0; b < 2; b++) begin : gen_b
    // g_named — THE WITNESS: bare member of an INPUT PORT, named conn, in gen
    ch37 i_gn (
      .rd_i(pin_i.rd),
      .addr_i(pin_i.addr),
      .ack_o(ack_o[b])
    );
    // g_pos — the same actuals connected POSITIONALLY
    ch37 i_gp (pin_i.rd, pin_i.addr, ack_o[2+b]);
    // g_loc — base is a module-LOCAL variable, not a port
    ch37 i_gl (
      .rd_i(locv.rd),
      .addr_i(locv.addr),
      .ack_o(ack_o[4+b])
    );
    // g_nest — NESTED member select through two levels
    ch37 i_gnst (
      .rd_i(onest_i.inner.rd),
      .addr_i(onest_i.inner.addr),
      .ack_o(ack_o[6+b])
    );
    // g_psel — member + PART SELECT (flash_phy.sv:133's shape)
    ch37 i_gps (
      .rd_i(pin_i.rd),
      .addr_i(pin_i.addr[0 +: 8]),
      .ack_o(ack_o[8+b])
    );
    // g_op — member INSIDE an operation (flash_phy.sv:124's shape)
    ch37 i_gop (
      .rd_i(pin_i.rd & (b == 0)),
      .addr_i(pin_i.addr),
      .ack_o(ack_o[10+b])
    );
    // g_whole — the WHOLE struct port passed through (control: plain ref)
    ch37w i_gw (
      .all_i(pin_i),
      .ack_o(ack_o[12+b])
    );
  end

  // ---- p_* : the SAME shapes in the PLAIN module body (no generate)
  // p_named — bare member of an INPUT PORT, named conn, no generate
  ch37 i_pn (
    .rd_i(pin_i.rd),
    .addr_i(pin_i.addr),
    .ack_o(ack_o[14])
  );
  // p_pos — positional, no generate
  ch37 i_pp (pin_i.rd, pin_i.addr, ack_o[15]);
  // p_loc — module-local base, no generate
  ch37 i_pl (
    .rd_i(locv.rd),
    .addr_i(locv.addr),
    .ack_o()
  );
  // p_nest — nested member, no generate
  ch37 i_pnst (
    .rd_i(lonest.inner.rd),
    .addr_i(lonest.inner.addr),
    .ack_o()
  );

endmodule
