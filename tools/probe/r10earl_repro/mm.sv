// r10earl5 mm.sv — the `sha_word_t` cluster (hmac_pkg.sv:17), 6 heads and the
// LARGEST remaining class after the pass-5 laws.
//     failLhs logic_typespec 'sha_word_t' hmac_pkg.sv:17:11
//     failRhs logic_typespec ''           :26:14
// hmac_pkg.sv:17 is `typedef logic [31:0] sha_word_t;` and :26 is
// `localparam sha_word_t InitHash [8] = '{...}` — so golden's UNPACKED-ARRAY
// localparam binds the TYPEDEF's own (named) logic_typespec as its element
// type where we mint a fresh ANONYMOUS one at the declaration.  Same family as
// pass 4's § pkgTypespecInstanceIsTop and TypeEmit's pkgTopTypedefTs.
package mp;

  localparam int NumRound = 4;

  typedef logic [31:0] sha_word_t;

  // row A — the hmac shape: unpacked array of a TYPEDEF element type
  localparam sha_word_t InitHash [4] = '{
    32'h 6a09_e667, 32'h bb67_ae85, 32'h 3c6e_f372, 32'h a54f_f53a
  };

  // row B — the same declaration with the type written out (control)
  localparam logic [31:0] RawHash [4] = '{
    32'h 6a09_e667, 32'h bb67_ae85, 32'h 3c6e_f372, 32'h a54f_f53a
  };

  // row C — a SCALAR localparam of the same typedef (control)
  localparam sha_word_t OneWord = 32'h 6a09_e667;

  // row D — a struct member of the typedef type (control; hmac's sha_fifo_t)
  typedef struct packed {
    sha_word_t data;
    logic [3:0] mask;
  } sha_fifo_t;

endpackage

// The module only DECLARES a signal of the struct typedef and reads one bit of
// it.  Every richer body drags in an unrelated divergence and masks the
// element-typespec law this witness is about — a read of the array parameter
// (`mp::InitHash[0]`) folds its bit-select differently, and a struct-pattern
// cont-assign (`'{data: 32'h0, mask: 4'h1}`) re-encodes the member constant
// HEX-vs-UINT in the ELAB view.  Both are ranked as fresh residues.
module mchild (input logic clk_i, output logic o);
  mp::sha_fifo_t f;
  assign o = clk_i ^ f.data[0];
endmodule

module mm (input logic clk_i, output logic o);
  mchild u_m (.clk_i(clk_i), .o(o));
endmodule
