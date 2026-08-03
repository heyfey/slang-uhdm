package cfgpkg;
  localparam W32 = 32;
  localparam W1  = 1;
  typedef enum logic [1:0] { NA = 0, NB = 1 } noc_e;
  typedef struct packed {
    int unsigned A_refcast;
    int unsigned A_litcast;
    bit          B_refcast;
    bit          B_bitcast;
    bit [15:0]   D_dec;
    logic [63:0] E_hex;
    int unsigned F_plainref;
    int unsigned G_plainlit;
    noc_e        N_enum;
    logic [1:0][63:0] R_rep;
    logic [1:0][63:0] C_cast1;
    logic [1:0][63:0] C_cast2;
  } src_t;
  localparam src_t SRC = '{
    A_refcast: unsigned'(W32),
    A_litcast: unsigned'(5),
    B_refcast: unsigned'(W1),
    B_bitcast: bit'(W1),
    D_dec: 16'd7,
    E_hex: 64'h5,
    F_plainref: W32,
    G_plainlit: 9,
    N_enum: NA,
    R_rep: {2{64'h0}},
    C_cast1: 128'({64'h3}),
    C_cast2: 128'({64'h3, 64'h4})
  };
  typedef struct packed {
    int unsigned M_read;
    int unsigned M_readlit;
    bit          M_readbit;
    logic [63:0] M_readhex;
    bit [15:0]   M_readdec;
    int unsigned M_tern;
    int unsigned M_clog;
    bit          M_bitcast;
    int unsigned M_ucastvar;
    int unsigned M_ucastlit;
    int unsigned M_arith;
    int unsigned M_or;
    int unsigned M_lit;
    noc_e        M_enum;
    logic [1:0][63:0] M_rep;
  } dst_t;
endpackage

package bldpkg;
  function automatic cfgpkg::dst_t build(cfgpkg::src_t S);
    bit lv_bit = (S.A_refcast == 32) ? 1'b1 : 1'b0;
    int unsigned lv_int = $clog2(S.A_refcast);
    cfgpkg::dst_t d;
    d.M_read     = S.A_refcast;
    d.M_readlit  = S.A_litcast;
    d.M_readbit  = S.B_bitcast;
    d.M_readhex  = S.E_hex;
    d.M_readdec  = S.D_dec;
    d.M_tern     = (S.A_refcast == 32) ? 11 : 22;
    d.M_clog     = $clog2(S.A_refcast);
    d.M_bitcast  = bit'(lv_bit);
    d.M_ucastvar = unsigned'(lv_int);
    d.M_ucastlit = unsigned'(2);
    d.M_arith    = d.M_read - lv_int;
    d.M_or       = S.F_plainref | S.G_plainlit;
    d.M_lit      = 32;
    d.M_enum     = S.N_enum;
    d.M_rep      = S.R_rep;
    return d;
  endfunction
endpackage

module top();
  parameter cfgpkg::dst_t CFG = bldpkg::build(cfgpkg::SRC);
  sub #(.W(CFG.M_read)) u1();
endmodule

module sub #(parameter int unsigned W = 2)();
  if (W == 32) begin : g32
    wire x;
  end else begin : gother
    wire y;
  end
endmodule
