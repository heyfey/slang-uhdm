// r10earl52 arm a4 — the REST of the shapes `ovEnc8` accepts, written as
// NON-OVERRIDDEN localparams.  This is the BLAST-RADIUS arm: dropping the
// `overridden` gate on the pass-8/28 encoding pipeline exposes every one of
// these, so each has to be measured against golden BEFORE the gate moves.
//
// Also pins WHERE the rule lives: a submodule instance (elaborated, not top)
// and a package (no elab view at all).
package a4p_earl52;
  localparam int  PK_int  = 1'b1;      // package `int` <- 1-bit BIN
  localparam int  PK_h    = 4'h8;
  localparam bit [7:0] PK_src = 8'hab;
endpackage

module a4sub_earl52 ();
  localparam int S_int  = 1'b1;        // same shape, one instance down
  localparam int S_h    = 4'h8;
  localparam int S_pk   = a4p_earl52::PK_src;
endmodule

module a4_earl52 ();
  a4sub_earl52 u_sub ();

  // --- CONCAT / REPLICATION initialisers
  localparam bit [3:0] CA = 4'ha;
  localparam bit [3:0] CB = 4'hb;
  localparam int          K_cat  = {CA, CB};
  localparam logic [7:0]  K_catv = {CA, CB};
  localparam int          K_cat1 = {CA};
  localparam int          K_rep  = {2{4'h5}};
  localparam int          K_litc = {4'ha, 4'hb};
  localparam bit [7:0]    K_catb = {CA, CB};

  // --- PARAM-REF hops at widths > 1 (the scalar-skip rule does NOT apply)
  localparam bit [7:0] H_src8 = 8'hab;
  localparam int       H_i8   = H_src8;
  localparam logic [7:0] H_l8 = H_src8;
  localparam int       H_i8b  = 8'b10101011;
  localparam int       H_hop2 = H_i8;          // two hops
  localparam bit [1:0] H_src2 = 2'b10;
  localparam int       H_i2   = H_src2;

  // --- plain same-scope hop of a 1-bit source
  localparam bit       H_s1   = 1'b1;
  localparam int       H_i1   = H_s1;
  localparam logic [7:0] H_l1 = H_s1;
  localparam bit [7:0] H_b1   = H_s1;

  // --- an unsized based literal (adjustSize's orig_size == -1 tail)
  localparam int       U_ub   = 'h8;
  localparam int       U_ubb  = 'b1;

  // --- a NEGATIVE decimal and an expression that is already INT
  localparam int       N_neg  = -1;
  localparam int       N_sub  = 4'h8 - 4'h8;

  // --- enum / string / real / struct targets (the other arms must keep them)
  typedef enum logic [1:0] { E0, E1 } e_t;
  localparam e_t       E_p    = E1;
  localparam string    S_p    = "hi";
  localparam real      R_p    = 1.5;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } sp_t;
  localparam sp_t      P_p    = '{a: 4'ha, b: 4'hb};

  // --- unpacked array
  localparam bit [1:0] UA [2] = '{2'h1, 2'h2};
endmodule
