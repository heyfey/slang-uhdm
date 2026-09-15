// v3_shape35 — THE BOUND SHAPE axis, independently written, with the NAME the
// judge reads (vpiName on the ref_obj / hier_path leaf) as the target: a plain
// param ref, a package-qualified ref, a struct-param MEMBER read (hier path),
// arithmetic, $clog2, a literal, a sized literal, a 2-D member, an unpacked
// member dim, a signed member, a member typed by a NAMED typedef with its own
// dim, and an enum member with a symbolic base.
package shp35;
  localparam int QW = 11;
  typedef struct packed {
    int XLEN;
    int YLEN;
  } scfg_t;
  localparam scfg_t SCfg = '{XLEN: 32, YLEN: 16};
endpackage

typedef logic [shp35::QW-1:0] named_vec35_t;

module v3_shape35 #(parameter int W = 8, parameter int N = 6) (input logic clk);
  localparam int LW = W + 2;
  localparam type shp_t = struct packed {
    logic [W-1:0]                 s_minus;      // param ref minus one
    logic [W:0]                   s_bare;       // bare param ref
    logic [7:0]                   s_lit;        // literal
    logic [8'd9:0]                s_sized;      // sized literal
    logic [W+1:0]                 s_add;        // ADD
    logic [1+W:0]                 s_add_rev;    // ADD, other order
    logic [W*2-1:0]               s_mul;        // multiply
    logic [(W*2)-1:0]             s_pmul;       // parenthesised multiply
    logic [W/2-1:0]               s_div;        // divide
    logic [(W<<1)-1:0]            s_shift;      // shift
    logic [$clog2(N)-1:0]         s_clog;       // $clog2
    logic [LW-1:0]                s_local;      // localparam read
    logic [shp35::QW-1:0]         s_pkg;        // QUALIFIED package parameter
    logic [shp35::SCfg.XLEN-1:0]  s_member;     // struct-param MEMBER read
    logic signed [W-1:0]          s_signed;     // signed member
    logic [W-1:0][1:0]            s_2d;         // two packed dims
    named_vec35_t                 s_named;      // a NAMED typedef member
    named_vec35_t [W-1:0]         s_named_dim;  // named typedef + packed dim
  };
  shp_t sv;

  // the same shapes NOT under a type parameter — the control the law must not
  // touch: an anonymous struct on a variable.
  struct packed {
    logic [W-1:0]                c_minus;
    logic [shp35::SCfg.XLEN-1:0] c_member;
  } cv;

  always_comb begin
    sv = '0;
    cv = '0;
  end
endmodule
