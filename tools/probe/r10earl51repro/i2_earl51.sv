// i2 — the SECOND cut.  i1 proved the discriminator is the STRUCT-MEMBER LHS
// (golden folds every plain-net-LHS cast and keeps EVERY member-LHS one), but
// i1 does not REPRODUCE the head, because our side matches there by SHARING
// the def cont_assign: `output i1p::st_t s` elaborates to a struct_NET, and
// the `dottedLhs` net-base test then keeps the share.
//
// Earlgrey's `output tlul_pkg::tl_h2d_t tl_o` elaborates to a struct_VAR on our
// side.  tl_h2d_t differs from i1p::st_t in two ways: it has an ENUM-typed
// member and a NESTED packed struct member.  This arm carries both, so that
// our side takes the fresh-cont_assign path and the FOLD — the head's shape.
//
// It also widens the RHS axis on the member-LHS side: size cast, param binary
// op, constant ternary, bare param ref, unbased literal, plain literal.
package i2p;
  parameter int unsigned SZW = 2;
  parameter int unsigned AW  = 32;
  typedef enum logic [2:0] {
    OP_A = 3'h0,
    OP_B = 3'h1
  } op_e;
  typedef struct packed {
    logic [6:0] rsvd;
    logic       en;
  } user_t;
  typedef struct packed {
    logic                valid;
    op_e                 opcode;
    logic [2:0]          param;
    logic [SZW-1:0]      size;
    logic [AW-1:0]       address;
    logic [SZW-1:0]      k2;
    logic [SZW-1:0]      k3;
    logic [SZW-1:0]      k4;
    logic [SZW-1:0]      k5;
    logic [SZW-1:0]      k6;
    user_t               user;
    logic                ready;
  } h2d_t;
endpackage

module i2_sram #(
  parameter int SramAw = 12,
  parameter int SramDw = 32,
  parameter logic [i2p::AW-1:0] BaseAddr = 'h0
) (
  input  logic             req,
  input  logic [SramAw-1:0] addr,
  output i2p::h2d_t        tl_o,
  // the plain-net TWIN of every member cell below
  output logic [1:0]       n_size,
  output logic [1:0]       n_k2,
  output logic [1:0]       n_k3,
  output logic [1:0]       n_k4,
  output logic [1:0]       n_k5
);
  localparam int unsigned SRAM_DWB = $clog2(SramDw/8);
  localparam int unsigned LP2      = 2;

  // --- member-LHS cells ------------------------------------------------
  assign tl_o.valid   = req;                       // bare signal ref
  assign tl_o.size    = i2p::SZW'(SRAM_DWB);       // THE HEAD's shape
  assign tl_o.k2      = i2p::SZW'(LP2);            // cast of a plain localparam
  assign tl_o.k3      = SRAM_DWB[1:0] | 2'h0;      // an OPERATION, no cast
  assign tl_o.k4      = SRAM_DWB;                  // BARE localparam ref
  assign tl_o.k5      = 2'h1;                      // a plain literal
  assign tl_o.k6      = '0;                        // unbased literal
  assign tl_o.param   = '0;
  assign tl_o.address = BaseAddr | {{(i2p::AW-SramAw-SRAM_DWB){1'b0}}, addr};
  assign tl_o.user    = '0;
  assign tl_o.ready   = 1'b1;
  assign tl_o.opcode  = i2p::OP_A;

  // --- the plain-net TWINS ---------------------------------------------
  assign n_size = i2p::SZW'(SRAM_DWB);
  assign n_k2   = i2p::SZW'(LP2);
  assign n_k3   = SRAM_DWB[1:0] | 2'h0;
  assign n_k4   = SRAM_DWB;
  assign n_k5   = 2'h1;
endmodule
