// r10earl93 g6 -- THE PACKAGE / IMPORT / INSTANCE-ACTUAL grid, plus the
// get_value BAIL rows (an operand constant's UHDM encoding decides whether
// golden folds at all).  MEASUREMENT ONLY.
package g6_pkg;
  localparam int unsigned PW = 64;
  localparam p_64  = 64'(64'hFFFFFFFFFFFFFFFF);
  localparam p_96  = 96'(64'hFFFFFFFFFFFFFFFF);
  localparam p_128 = 128'(64'd7);
  localparam logic [63:0] p_t64 = 64'(64'd1);
  localparam p_pw  = PW'(64'd1);
endpackage
module g6_child #(parameter int unsigned W = 64, parameter logic [63:0] SEED = 64'd0) ();
  localparam logic [W-1:0] L = W'(64'd1) ^ 64'd0;
  localparam logic [W-1:0] M = W'(64'd1);
  wire [63:0] dummy; assign dummy = SEED;
endmodule
module g6;
  import g6_pkg::*;
  localparam i_64 = p_64;
  // instance PARAMETER actual carrying a size cast
  g6_child #(.W(64),  .SEED(64'(64'hFFFFFFFFFFFFFFFF))) u1 ();
  g6_child #(.W(96),  .SEED(96'(64'hFFFFFFFFFFFFFFFF))) u2 ();
  g6_child #(.W(128), .SEED(128'(64'd3)))                u3 ();
  // THE get_value BAIL ROWS -- the operand constant's ENCODING, not its width
  localparam b_hex96   = 96'(96'hFFFFFFFFFFFFFFFFFFFFFFFF); // HEX  sz96 -> bail
  localparam b_hex96s  = 96'(96'h00000000FFFFFFFFFFFFFFFF); // HEX  sz96 -> bail?
  localparam b_dec96   = 96'(96'd5);                        // DEC  sz96 -> folds
  localparam b_dec96b  = 96'(96'd18446744073709551615);     // DEC  sz96, fits u64
  localparam b_bin96   = 96'(96'b101);                      // BIN  sz96 -> bail?
  localparam b_hex64   = 64'(64'hFFFFFFFFFFFFFFFF);         // HEX  sz64 -> folds
  localparam b_dec64   = 64'(64'd5);
  localparam b_unb     = 64'(5);                            // unbased decimal
  localparam b_ubu     = 64'('1);                           // unbased unsized
endmodule
