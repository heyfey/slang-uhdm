// v19 — a PATTERN-VALUED ELEMENT plus a MEMBER SELECT, so the landed
// member-select rule flattens `UU` on BOTH binaries.  The drain's clone then
// has an all-constant operand list to copy while golden's leftover is still
// the TAGGED tree: this arm says whether that is a MOVED-WRONG (pristine was
// wrong too) or an AWAY (pristine was right).
package pk;
  typedef struct packed { int unsigned x; int unsigned y; } n_t;
  typedef struct packed { n_t a; int unsigned b; } in_t;
  typedef struct packed { in_t u; int unsigned d; } c_t;
  localparam n_t NA = '{x: 1, y: 2};
  localparam in_t UU = '{a: NA, b: 3};
  localparam int unsigned AA = UU.b;
  function automatic c_t mk();
    c_t c; c.u = UU; c.d = 64; return c;
  endfunction
  localparam c_t C = mk();
endpackage

module kid #(
    parameter pk::c_t P = pk::C
) (output logic o);
  localparam pk::in_t S = P.u;
  assign o = 1'b0;
endmodule

module dut(output logic o);
  kid k0 (.o(o));
endmodule
