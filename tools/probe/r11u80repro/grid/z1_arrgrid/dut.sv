// r11u80 z1 -- THE GOLDEN GRID for the unpacked HOLDER BUILDER (LAW A):
// element kinds x dimension spellings x net/var x typedef chains, asked of
// golden all at once.  vh_arrelem/vb_unpackedfaces measured the ten element
// spellings and four dimension spellings; this arm asks the faces they did
// not: the plain-integral element kinds beyond `logic` (int/bit/byte/real/
// string/reg), the `var` qualifier on an aggregate, a typedef CHAIN to an
// aggregate, a typedef'd INTEGRAL element net- and var-declared, three
// unpacked dimensions, a descending dimension and an expression size.
package pz;
  typedef struct packed { logic [7:0] x; logic [7:0] y; } sl_t;   // all-logic
  typedef struct packed { int x; logic [7:0] y; }         si_t;   // int member
  typedef union  packed { logic [15:0] a; logic [15:0] b; } un_t;
  typedef enum logic [1:0] { ZA, ZB } en_t;
  typedef logic [3:0] w_t;
  typedef reg   [3:0] r_t;
  typedef bit  [3:0] b_t;
  typedef sl_t        sl2_t;      // a typedef CHAIN to an all-logic struct
  typedef si_t        si2_t;      // a typedef CHAIN to an int-member struct

  // the plain-integral element kinds the ten-row table did not ask
  int          z_int    [0:1];
  bit   [3:0]  z_bit    [0:1];
  byte         z_byte   [0:1];
  real         z_real   [0:1];
  string       z_str    [0:1];
  reg   [7:0]  z_reg    [0:1];
  var   logic [7:0] z_varlog [0:1];   // the VAR qualifier on the plain integral

  // a typedef'd INTEGRAL element, variable- and net-declared
  w_t          z_tdw    [0:1];
  r_t          z_tdr    [0:1];
  wire  w_t    z_ntdw   [0:1];

  // typedef CHAINS to an aggregate
  sl2_t        z_sl2    [0:1];
  si2_t        z_si2    [0:1];

  // the VAR qualifier on an aggregate element
  var   si_t   z_vsi    [0:1];
  var   en_t   z_ven    [0:1];
  var   un_t   z_vun    [0:1];

  // dimension spellings
  logic [7:0]  z_3d     [0:1][0:2][0:3];   // THREE unpacked dims: 2*3*4 = 24
  logic [7:0]  z_szexp  [2*2];             // an EXPRESSION size
  logic [7:0]  z_desc   [3:1];             // a DESCENDING dimension

  // the boundary faces the rule has to get right to be one rule
  var   sl_t   z_vsl    [0:1];   // VAR on an ALL-LOGIC struct: does the
                                 // typespec override still win?
  const logic [7:0] z_klog [0:1] = '{8'd1, 8'd2};  // the CONST qualifier
  wire  sl2_t  z_nsl2   [0:1];             // net keyword + a typedef CHAIN
  typedef logic [7:0] arr2_t [0:1][0:2];
  arr2_t       z_td2;                      // a typedef'd TWO-dim array
  typedef logic [7:0] arr1_t [0:1];
  arr1_t       z_tdplus [0:2];   // a typedef'd array PLUS a declarator dim

  // the remaining ELEMENT KINDS, so the kind table is measured not inferred
  shortint     z_short  [0:1];
  longint      z_long   [0:1];
  integer      z_integ  [0:1];
  time         z_time   [0:1];
  shortreal    z_sreal  [0:1];
  logic signed [7:0] z_slog [0:1];         // a WRITTEN signed keyword
  b_t          z_nbit   [0:1];             // a BIT typedef, net-road spelling
endpackage

module dut (output logic [31:0] o);
  import pz::*;
  for (genvar i = 0; i < 1; i = i + 1) begin : gv
    logic [31:0] z_int;     assign z_int     = 32'd1;
    logic [31:0] z_bit;     assign z_bit     = 32'd2;
    logic [31:0] z_byte;    assign z_byte    = 32'd3;
    logic [31:0] z_reg;     assign z_reg     = 32'd4;
    logic [31:0] z_varlog;  assign z_varlog  = 32'd5;
    logic [31:0] z_tdw;     assign z_tdw     = 32'd6;
    logic [31:0] z_tdr;     assign z_tdr     = 32'd7;
    logic [31:0] z_ntdw;    assign z_ntdw    = 32'd8;
    logic [31:0] z_sl2;     assign z_sl2     = 32'd9;
    logic [31:0] z_si2;     assign z_si2     = 32'd10;
    logic [31:0] z_vsi;     assign z_vsi     = 32'd11;
    logic [31:0] z_ven;     assign z_ven     = 32'd12;
    logic [31:0] z_vun;     assign z_vun     = 32'd13;
    logic [31:0] z_3d;      assign z_3d      = 32'd14;
    logic [31:0] z_szexp;   assign z_szexp   = 32'd15;
    logic [31:0] z_desc;    assign z_desc    = 32'd16;
    logic [31:0] z_vsl;     assign z_vsl     = 32'd17;
    logic [31:0] z_klog;    assign z_klog    = 32'd18;
    logic [31:0] z_nsl2;    assign z_nsl2    = 32'd19;
    logic [31:0] z_td2;     assign z_td2     = 32'd20;
    logic [31:0] z_tdplus;   assign z_tdplus = 32'd21;
    logic [31:0] z_short;   assign z_short = 32'd22;
    logic [31:0] z_long;   assign z_long = 32'd23;
    logic [31:0] z_integ;   assign z_integ = 32'd24;
    logic [31:0] z_time;   assign z_time = 32'd25;
    logic [31:0] z_sreal;   assign z_sreal = 32'd26;
    logic [31:0] z_slog;   assign z_slog = 32'd27;
    logic [31:0] z_nbit;   assign z_nbit = 32'd28;
  end
  assign o = gv[0].z_int  ^ gv[0].z_bit   ^ gv[0].z_byte ^ gv[0].z_reg
           ^ gv[0].z_varlog ^ gv[0].z_tdw ^ gv[0].z_tdr  ^ gv[0].z_ntdw
           ^ gv[0].z_sl2  ^ gv[0].z_si2   ^ gv[0].z_vsi  ^ gv[0].z_ven
           ^ gv[0].z_vun  ^ gv[0].z_3d    ^ gv[0].z_szexp ^ gv[0].z_desc
           ^ gv[0].z_vsl  ^ gv[0].z_klog  ^ gv[0].z_nsl2 ^ gv[0].z_td2
           ^ gv[0].z_tdplus ^ gv[0].z_short ^ gv[0].z_long ^ gv[0].z_integ
           ^ gv[0].z_time ^ gv[0].z_sreal ^ gv[0].z_slog ^ gv[0].z_nbit;
endmodule
