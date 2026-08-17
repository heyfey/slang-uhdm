// r10earl56 a1 — THE DISTANCE GRID.  In a gen-scope CONT-ASSIGN's SELECT
// BOUND, WHERE does golden fold a parameter reference to a constant and where
// does it keep the ref_obj?  The axis this arm sweeps is the DECLARING SCOPE of
// the referenced parameter relative to the USE SITE's own gen scope:
//
//   d0  the parameter is declared in the SAME gen scope as the cont-assign
//   d1  one gen scope OUT (the use is one level deeper)
//   dM  the enclosing MODULE's own parameter / localparam
//   dP  a PACKAGE parameter
//
// crossed with the POSITION of the reference: an indexed_part_select's WIDTH,
// its BASE, a simple part_select's LEFT and RIGHT bound, a bit_select INDEX,
// and (control) the bare cont-assign RHS.
//
// Earlgrey's head is the d0 x ips-WIDTH cell: prim_fifo_sync.sv:70
// `assign wptr_value = fifo_wptr[0+:PTRV_W];` inside `gen_normal_fifo`, where
// PTRV_W is that gen scope's OWN localparam.  Golden keeps the ref_obj there.
package pk56;
  parameter int PKW = 3;
endpackage

module a1_sub56 #(parameter int unsigned Depth = 4) (
  input  logic        clk_i,
  input  logic [31:0] din,
  output logic [31:0] o
);
  localparam int unsigned MW = 3;          // dM: module localparam, typed
  localparam          MU = 3;              // dM: module localparam, UNTYPED

  if (Depth == 0) begin : gen_zero
    assign o = din;
  end else begin : gen_norm
    localparam int unsigned D0W = 3;       // d0: this gen scope's own, typed
    localparam          D0U = 3;           // d0: this gen scope's own, UNTYPED

    // ---- d0 x every position -------------------------------------------
    logic [31:0] w_ipsw, w_ipsb, w_psl, w_psr, w_bit, w_bare;
    assign w_ipsw = {29'b0, din[0 +: D0W]};        // ips WIDTH   <= THE HEAD
    assign w_ipsb = {28'b0, din[D0W +: 4]};        // ips BASE
    assign w_psl  = {29'b0, din[D0W-1:0]};         // part_select LEFT  (op)
    assign w_psr  = {28'b0, din[3:D0W-3]};         // part_select RIGHT (op)
    assign w_bit  = {31'b0, din[D0W]};             // bit_select INDEX
    assign w_bare = {29'b0, D0W[2:0]};             // bare read (control)
    // d0 UNTYPED
    logic [31:0] u_ipsw, u_ipsb, u_psl, u_bit;
    assign u_ipsw = {29'b0, din[0 +: D0U]};
    assign u_ipsb = {28'b0, din[D0U +: 4]};
    assign u_psl  = {29'b0, din[D0U-1:0]};
    assign u_bit  = {31'b0, din[D0U]};

    // ---- dM x every position -------------------------------------------
    logic [31:0] m_ipsw, m_ipsb, m_psl, m_bit;
    assign m_ipsw = {29'b0, din[0 +: MW]};
    assign m_ipsb = {28'b0, din[MW +: 4]};
    assign m_psl  = {29'b0, din[MW-1:0]};
    assign m_bit  = {31'b0, din[MW]};
    logic [31:0] mu_ipsw, mu_psl;
    assign mu_ipsw = {29'b0, din[0 +: MU]};
    assign mu_psl  = {29'b0, din[MU-1:0]};

    // ---- dM x the MODULE PARAMETER (overridable) -----------------------
    logic [31:0] p_ipsw, p_psl;
    assign p_ipsw = {28'b0, din[0 +: Depth]};
    assign p_psl  = {28'b0, din[Depth-1:0]};

    // ---- dP: a PACKAGE parameter ---------------------------------------
    logic [31:0] k_ipsw, k_psl;
    assign k_ipsw = {29'b0, din[0 +: pk56::PKW]};
    assign k_psl  = {29'b0, din[pk56::PKW-1:0]};

    // ---- d1: the SAME d0 localparam read ONE SCOPE DEEPER ---------------
    if (Depth != 0) begin : gen_in
      logic [31:0] n_ipsw, n_ipsb, n_psl, n_bit;
      assign n_ipsw = {29'b0, din[0 +: D0W]};
      assign n_ipsb = {28'b0, din[D0W +: 4]};
      assign n_psl  = {29'b0, din[D0W-1:0]};
      assign n_bit  = {31'b0, din[D0W]};
    end

    assign o = w_ipsw ^ w_ipsb ^ w_psl ^ w_psr ^ w_bit ^ w_bare ^
               u_ipsw ^ u_ipsb ^ u_psl ^ u_bit ^
               m_ipsw ^ m_ipsb ^ m_psl ^ m_bit ^ mu_ipsw ^ mu_psl ^
               p_ipsw ^ p_psl ^ k_ipsw ^ k_psl;
  end
endmodule

// A MODULE-SCOPE control: the same positions with NO gen scope at all.
module a1_plain56 (input logic [31:0] din, output logic [31:0] o);
  localparam int unsigned PW = 3;
  logic [31:0] q_ipsw, q_ipsb, q_psl, q_bit;
  assign q_ipsw = {29'b0, din[0 +: PW]};
  assign q_ipsb = {28'b0, din[PW +: 4]};
  assign q_psl  = {29'b0, din[PW-1:0]};
  assign q_bit  = {31'b0, din[PW]};
  assign o = q_ipsw ^ q_ipsb ^ q_psl ^ q_bit;
endmodule

module a1_earl56 (input logic clk_i, input logic [31:0] din,
                 output logic [31:0] o1, output logic [31:0] o2);
  a1_sub56 #(.Depth(4)) u_s (.clk_i(clk_i), .din(din), .o(o1));
  a1_plain56 u_p (.din(din), .o(o2));
endmodule
