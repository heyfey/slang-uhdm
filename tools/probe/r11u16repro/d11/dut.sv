// d11 — THE SIZE AND ENCODING MATRIX.  `writeCont_assign` hands the member
// slice to `adjustSize` with the LHS typespec as `bindVariable` finds it, and
// adjustSize then REPLACES that typespec with the constant's OWN (the member's)
// before choosing a branch — so the LHS width only ever reaches `VpiSize`.
// Every cell here separates one of those two roles.
package p;
  typedef struct packed {
    int unsigned n;      // int_typespec member
    logic [63:0] base;   // logic_typespec member
    byte         b;      // byte_typespec member
    logic        f;
  } cfg_t;
  function automatic cfg_t build();
    cfg_t r;
    r.n    = 3;
    r.base = 64'hDEAD_BEEF_0000_1234;
    r.b    = 8'h5a;
    r.f    = 1'b1;
    return r;
  endfunction
endpackage

module dut #(parameter p::cfg_t CFG = p::build()) (
    output logic [63:0] o_wide64,
    output logic [7:0]  o_int8,
    output logic [7:0]  o_log8,
    output logic [63:0] o_ps,
    output logic [7:0]  o_ca,
    output logic [7:0]  o_cb,
    output logic [7:0]  o_byte8,
    output logic [31:0] o_byte32,
    output logic [63:0] o_gen,
    output logic [7:0]  o_nda
);
  wire [7:0] w8 = CFG.n;              // net-decl assign, 8-bit target
  assign o_wide64      = CFG.base;    // logic member, LHS == member width
  assign o_int8        = CFG.n;       // int member into an 8-bit bound LHS
  assign o_log8        = CFG.base;    // logic member into an 8-bit bound LHS
  assign o_ps[7:0]     = CFG.n;       // PART-SELECT target, 8 bits wide
  assign o_ps[63:8]    = '0;
  assign {o_ca, o_cb}  = CFG.base;    // CONCAT target, 16 bits
  assign o_byte8       = CFG.b;       // byte member, 8-bit LHS
  assign o_byte32      = CFG.b;       // byte member, 32-bit LHS
  assign o_nda         = w8;
  generate
    if (1) begin : g
      wire [7:0] gw8;
      assign gw8 = CFG.n;             // GEN-LOCAL 8-bit target: no bind
    end
  endgenerate
  assign o_gen = {56'd0, g.gw8};
endmodule
