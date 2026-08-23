// r10earl77 -- purpose-built PORT-KIND grid: direction x written type shape.
// MEASUREMENT ONLY.  Golden is Surelog; the question is which Nets/Variables
// container each ANSI port's backing object lands in.
package p77;
  typedef logic [7:0]      v8_t;
  typedef logic            s1_t;
  typedef bit   [7:0]      b8_t;
  typedef enum logic [1:0] { E770, E771, E772 } e_t;
  typedef struct packed { logic [3:0] sa; logic [3:0] sb; } st_t;
  typedef logic [1:0][3:0] m_t;
  parameter int W77 = 8;
  typedef logic [W77-1:0]  pw_t;
endpackage

typedef logic [7:0] u8_t;

module leaf77d import p77::*; (
  input                     i_bare,
  input  logic              i_logicsc,
  input  logic [7:0]        i_logicvec,
  input  wire               i_wiresc,
  input  wire [7:0]         i_wirevec,
  input  p77::v8_t          i_pkgvec,
  input  v8_t               i_impvec,
  input  p77::e_t           i_pkgenum,
  input  e_t                i_impenum,
  input  p77::st_t          i_pkgstruct,
  input  st_t               i_impstruct,
  input  u8_t               i_unitvec,
  input  p77::pw_t          i_pkgpw,
  input  p77::m_t           i_pkgmulti,
  input  p77::b8_t          i_pkgbit,
  input  p77::s1_t          i_pkgscalar,
  input  var logic [7:0]    i_varvec,
  input  p77::v8_t [1:0]    i_pkgvecdim,
  input  reg [7:0]          i_regvec,
  input  var p77::v8_t      i_varpkgvec,
  output                    o_bare,
  output logic              o_logicsc,
  output logic [7:0]        o_logicvec,
  output wire               o_wiresc,
  output wire [7:0]         o_wirevec,
  output p77::v8_t          o_pkgvec,
  output v8_t               o_impvec,
  output p77::e_t           o_pkgenum,
  output e_t                o_impenum,
  output p77::st_t          o_pkgstruct,
  output st_t               o_impstruct,
  output u8_t               o_unitvec,
  output p77::pw_t          o_pkgpw,
  output p77::m_t           o_pkgmulti,
  output p77::b8_t          o_pkgbit,
  output p77::s1_t          o_pkgscalar,
  output var logic [7:0]    o_varvec,
  output p77::v8_t [1:0]    o_pkgvecdim,
  output reg [7:0]          o_regvec,
  output var p77::v8_t      o_varpkgvec
);
  assign o_bare = i_bare;
  assign o_logicsc = i_logicsc;
  assign o_logicvec = i_logicvec;
  assign o_wiresc = i_wiresc;
  assign o_wirevec = i_wirevec;
  assign o_pkgvec = i_pkgvec;
  assign o_impvec = i_impvec;
  assign o_pkgenum = i_pkgenum;
  assign o_impenum = i_impenum;
  assign o_pkgstruct = i_pkgstruct;
  assign o_impstruct = i_impstruct;
  assign o_unitvec = i_unitvec;
  assign o_pkgpw = i_pkgpw;
  assign o_pkgmulti = i_pkgmulti;
  assign o_pkgbit = i_pkgbit;
  assign o_pkgscalar = i_pkgscalar;
  assign o_varvec = i_varvec;
  assign o_pkgvecdim = i_pkgvecdim;
  assign o_regvec = i_regvec;
  assign o_varpkgvec = i_varpkgvec;
endmodule

module leaf77u import p77::*; (
  input                     i_bare,
  input  logic              i_logicsc,
  input  logic [7:0]        i_logicvec,
  input  wire               i_wiresc,
  input  wire [7:0]         i_wirevec,
  input  p77::v8_t          i_pkgvec,
  input  v8_t               i_impvec,
  input  p77::e_t           i_pkgenum,
  input  e_t                i_impenum,
  input  p77::st_t          i_pkgstruct,
  input  st_t               i_impstruct,
  input  u8_t               i_unitvec,
  input  p77::pw_t          i_pkgpw,
  input  p77::m_t           i_pkgmulti,
  input  p77::b8_t          i_pkgbit,
  input  p77::s1_t          i_pkgscalar,
  input  var logic [7:0]    i_varvec,
  input  p77::v8_t [1:0]    i_pkgvecdim,
  input  reg [7:0]          i_regvec,
  input  var p77::v8_t      i_varpkgvec,
  output                    o_bare,
  output logic              o_logicsc,
  output logic [7:0]        o_logicvec,
  output wire               o_wiresc,
  output wire [7:0]         o_wirevec,
  output p77::v8_t          o_pkgvec,
  output v8_t               o_impvec,
  output p77::e_t           o_pkgenum,
  output e_t                o_impenum,
  output p77::st_t          o_pkgstruct,
  output st_t               o_impstruct,
  output u8_t               o_unitvec,
  output p77::pw_t          o_pkgpw,
  output p77::m_t           o_pkgmulti,
  output p77::b8_t          o_pkgbit,
  output p77::s1_t          o_pkgscalar,
  output var logic [7:0]    o_varvec,
  output p77::v8_t [1:0]    o_pkgvecdim,
  output reg [7:0]          o_regvec,
  output var p77::v8_t      o_varpkgvec
);
  // no drivers
endmodule

module mid77;
  logic [7:0] c1_i_bare;
  logic [7:0] c1_o_bare;
  logic c1_i_logicsc;
  logic c1_o_logicsc;
  logic [7:0] c1_i_logicvec;
  logic [7:0] c1_o_logicvec;
  logic c1_i_wiresc;
  logic c1_o_wiresc;
  logic [7:0] c1_i_wirevec;
  logic [7:0] c1_o_wirevec;
  logic [7:0] c1_i_pkgvec;
  logic [7:0] c1_o_pkgvec;
  logic [7:0] c1_i_impvec;
  logic [7:0] c1_o_impvec;
  p77::e_t c1_i_pkgenum;
  p77::e_t c1_o_pkgenum;
  p77::e_t c1_i_impenum;
  p77::e_t c1_o_impenum;
  logic [7:0] c1_i_pkgstruct;
  logic [7:0] c1_o_pkgstruct;
  logic [7:0] c1_i_impstruct;
  logic [7:0] c1_o_impstruct;
  logic [7:0] c1_i_unitvec;
  logic [7:0] c1_o_unitvec;
  logic [7:0] c1_i_pkgpw;
  logic [7:0] c1_o_pkgpw;
  logic [7:0] c1_i_pkgmulti;
  logic [7:0] c1_o_pkgmulti;
  logic [7:0] c1_i_pkgbit;
  logic [7:0] c1_o_pkgbit;
  logic c1_i_pkgscalar;
  logic c1_o_pkgscalar;
  logic [7:0] c1_i_varvec;
  logic [7:0] c1_o_varvec;
  logic [7:0] c1_i_pkgvecdim;
  logic [7:0] c1_o_pkgvecdim;
  logic [7:0] c1_i_regvec;
  logic [7:0] c1_o_regvec;
  logic [7:0] c1_i_varpkgvec;
  logic [7:0] c1_o_varpkgvec;
  leaf77d u_c1 (
    .i_bare(c1_i_bare),
    .i_logicsc(c1_i_logicsc),
    .i_logicvec(c1_i_logicvec),
    .i_wiresc(c1_i_wiresc),
    .i_wirevec(c1_i_wirevec),
    .i_pkgvec(c1_i_pkgvec),
    .i_impvec(c1_i_impvec),
    .i_pkgenum(c1_i_pkgenum),
    .i_impenum(c1_i_impenum),
    .i_pkgstruct(c1_i_pkgstruct),
    .i_impstruct(c1_i_impstruct),
    .i_unitvec(c1_i_unitvec),
    .i_pkgpw(c1_i_pkgpw),
    .i_pkgmulti(c1_i_pkgmulti),
    .i_pkgbit(c1_i_pkgbit),
    .i_pkgscalar(c1_i_pkgscalar),
    .i_varvec(c1_i_varvec),
    .i_pkgvecdim(c1_i_pkgvecdim),
    .i_regvec(c1_i_regvec),
    .i_varpkgvec(c1_i_varpkgvec),
    .o_bare(c1_o_bare),
    .o_logicsc(c1_o_logicsc),
    .o_logicvec(c1_o_logicvec),
    .o_wiresc(c1_o_wiresc),
    .o_wirevec(c1_o_wirevec),
    .o_pkgvec(c1_o_pkgvec),
    .o_impvec(c1_o_impvec),
    .o_pkgenum(c1_o_pkgenum),
    .o_impenum(c1_o_impenum),
    .o_pkgstruct(c1_o_pkgstruct),
    .o_impstruct(c1_o_impstruct),
    .o_unitvec(c1_o_unitvec),
    .o_pkgpw(c1_o_pkgpw),
    .o_pkgmulti(c1_o_pkgmulti),
    .o_pkgbit(c1_o_pkgbit),
    .o_pkgscalar(c1_o_pkgscalar),
    .o_varvec(c1_o_varvec),
    .o_pkgvecdim(c1_o_pkgvecdim),
    .o_regvec(c1_o_regvec),
    .o_varpkgvec(c1_o_varpkgvec)
  );
  logic [7:0] c2_i_bare;
  logic [7:0] c2_o_bare;
  logic c2_i_logicsc;
  logic c2_o_logicsc;
  logic [7:0] c2_i_logicvec;
  logic [7:0] c2_o_logicvec;
  logic c2_i_wiresc;
  logic c2_o_wiresc;
  logic [7:0] c2_i_wirevec;
  logic [7:0] c2_o_wirevec;
  logic [7:0] c2_i_pkgvec;
  logic [7:0] c2_o_pkgvec;
  logic [7:0] c2_i_impvec;
  logic [7:0] c2_o_impvec;
  p77::e_t c2_i_pkgenum;
  p77::e_t c2_o_pkgenum;
  p77::e_t c2_i_impenum;
  p77::e_t c2_o_impenum;
  logic [7:0] c2_i_pkgstruct;
  logic [7:0] c2_o_pkgstruct;
  logic [7:0] c2_i_impstruct;
  logic [7:0] c2_o_impstruct;
  logic [7:0] c2_i_unitvec;
  logic [7:0] c2_o_unitvec;
  logic [7:0] c2_i_pkgpw;
  logic [7:0] c2_o_pkgpw;
  logic [7:0] c2_i_pkgmulti;
  logic [7:0] c2_o_pkgmulti;
  logic [7:0] c2_i_pkgbit;
  logic [7:0] c2_o_pkgbit;
  logic c2_i_pkgscalar;
  logic c2_o_pkgscalar;
  logic [7:0] c2_i_varvec;
  logic [7:0] c2_o_varvec;
  logic [7:0] c2_i_pkgvecdim;
  logic [7:0] c2_o_pkgvecdim;
  logic [7:0] c2_i_regvec;
  logic [7:0] c2_o_regvec;
  logic [7:0] c2_i_varpkgvec;
  logic [7:0] c2_o_varpkgvec;
  leaf77d u_c2 (
    .i_bare(c2_i_bare),
    .i_logicsc(c2_i_logicsc),
    .i_logicvec(c2_i_logicvec),
    .i_wiresc(c2_i_wiresc),
    .i_wirevec(c2_i_wirevec),
    .i_pkgvec(c2_i_pkgvec),
    .i_impvec(c2_i_impvec),
    .i_pkgenum(c2_i_pkgenum),
    .i_impenum(c2_i_impenum),
    .i_pkgstruct(c2_i_pkgstruct),
    .i_impstruct(c2_i_impstruct),
    .i_unitvec(c2_i_unitvec),
    .i_pkgpw(c2_i_pkgpw),
    .i_pkgmulti(c2_i_pkgmulti),
    .i_pkgbit(c2_i_pkgbit),
    .i_pkgscalar(c2_i_pkgscalar),
    .i_varvec(c2_i_varvec),
    .i_pkgvecdim(c2_i_pkgvecdim),
    .i_regvec(c2_i_regvec),
    .i_varpkgvec(c2_i_varpkgvec),
    .o_bare(c2_o_bare),
    .o_logicsc(c2_o_logicsc),
    .o_logicvec(c2_o_logicvec),
    .o_wiresc(c2_o_wiresc),
    .o_wirevec(c2_o_wirevec),
    .o_pkgvec(c2_o_pkgvec),
    .o_impvec(c2_o_impvec),
    .o_pkgenum(c2_o_pkgenum),
    .o_impenum(c2_o_impenum),
    .o_pkgstruct(c2_o_pkgstruct),
    .o_impstruct(c2_o_impstruct),
    .o_unitvec(c2_o_unitvec),
    .o_pkgpw(c2_o_pkgpw),
    .o_pkgmulti(c2_o_pkgmulti),
    .o_pkgbit(c2_o_pkgbit),
    .o_pkgscalar(c2_o_pkgscalar),
    .o_varvec(c2_o_varvec),
    .o_pkgvecdim(c2_o_pkgvecdim),
    .o_regvec(c2_o_regvec),
    .o_varpkgvec(c2_o_varpkgvec)
  );
  logic [7:0] c3_i_bare;
  logic [7:0] c3_o_bare;
  logic c3_i_logicsc;
  logic c3_o_logicsc;
  logic [7:0] c3_i_logicvec;
  logic [7:0] c3_o_logicvec;
  logic c3_i_wiresc;
  logic c3_o_wiresc;
  logic [7:0] c3_i_wirevec;
  logic [7:0] c3_o_wirevec;
  logic [7:0] c3_i_pkgvec;
  logic [7:0] c3_o_pkgvec;
  logic [7:0] c3_i_impvec;
  logic [7:0] c3_o_impvec;
  p77::e_t c3_i_pkgenum;
  p77::e_t c3_o_pkgenum;
  p77::e_t c3_i_impenum;
  p77::e_t c3_o_impenum;
  logic [7:0] c3_i_pkgstruct;
  logic [7:0] c3_o_pkgstruct;
  logic [7:0] c3_i_impstruct;
  logic [7:0] c3_o_impstruct;
  logic [7:0] c3_i_unitvec;
  logic [7:0] c3_o_unitvec;
  logic [7:0] c3_i_pkgpw;
  logic [7:0] c3_o_pkgpw;
  logic [7:0] c3_i_pkgmulti;
  logic [7:0] c3_o_pkgmulti;
  logic [7:0] c3_i_pkgbit;
  logic [7:0] c3_o_pkgbit;
  logic c3_i_pkgscalar;
  logic c3_o_pkgscalar;
  logic [7:0] c3_i_varvec;
  logic [7:0] c3_o_varvec;
  logic [7:0] c3_i_pkgvecdim;
  logic [7:0] c3_o_pkgvecdim;
  logic [7:0] c3_i_regvec;
  logic [7:0] c3_o_regvec;
  logic [7:0] c3_i_varpkgvec;
  logic [7:0] c3_o_varpkgvec;
  leaf77u u_c3 (
    .i_bare(c3_i_bare),
    .i_logicsc(c3_i_logicsc),
    .i_logicvec(c3_i_logicvec),
    .i_wiresc(c3_i_wiresc),
    .i_wirevec(c3_i_wirevec),
    .i_pkgvec(c3_i_pkgvec),
    .i_impvec(c3_i_impvec),
    .i_pkgenum(c3_i_pkgenum),
    .i_impenum(c3_i_impenum),
    .i_pkgstruct(c3_i_pkgstruct),
    .i_impstruct(c3_i_impstruct),
    .i_unitvec(c3_i_unitvec),
    .i_pkgpw(c3_i_pkgpw),
    .i_pkgmulti(c3_i_pkgmulti),
    .i_pkgbit(c3_i_pkgbit),
    .i_pkgscalar(c3_i_pkgscalar),
    .i_varvec(c3_i_varvec),
    .i_pkgvecdim(c3_i_pkgvecdim),
    .i_regvec(c3_i_regvec),
    .i_varpkgvec(c3_i_varpkgvec),
    .o_bare(c3_o_bare),
    .o_logicsc(c3_o_logicsc),
    .o_logicvec(c3_o_logicvec),
    .o_wiresc(c3_o_wiresc),
    .o_wirevec(c3_o_wirevec),
    .o_pkgvec(c3_o_pkgvec),
    .o_impvec(c3_o_impvec),
    .o_pkgenum(c3_o_pkgenum),
    .o_impenum(c3_o_impenum),
    .o_pkgstruct(c3_o_pkgstruct),
    .o_impstruct(c3_o_impstruct),
    .o_unitvec(c3_o_unitvec),
    .o_pkgpw(c3_o_pkgpw),
    .o_pkgmulti(c3_o_pkgmulti),
    .o_pkgbit(c3_o_pkgbit),
    .o_pkgscalar(c3_o_pkgscalar),
    .o_varvec(c3_o_varvec),
    .o_pkgvecdim(c3_o_pkgvecdim),
    .o_regvec(c3_o_regvec),
    .o_varpkgvec(c3_o_varpkgvec)
  );
  logic [7:0] cg_i_bare;
  logic [7:0] cg_o_bare;
  logic cg_i_logicsc;
  logic cg_o_logicsc;
  logic [7:0] cg_i_logicvec;
  logic [7:0] cg_o_logicvec;
  logic cg_i_wiresc;
  logic cg_o_wiresc;
  logic [7:0] cg_i_wirevec;
  logic [7:0] cg_o_wirevec;
  logic [7:0] cg_i_pkgvec;
  logic [7:0] cg_o_pkgvec;
  logic [7:0] cg_i_impvec;
  logic [7:0] cg_o_impvec;
  p77::e_t cg_i_pkgenum;
  p77::e_t cg_o_pkgenum;
  p77::e_t cg_i_impenum;
  p77::e_t cg_o_impenum;
  logic [7:0] cg_i_pkgstruct;
  logic [7:0] cg_o_pkgstruct;
  logic [7:0] cg_i_impstruct;
  logic [7:0] cg_o_impstruct;
  logic [7:0] cg_i_unitvec;
  logic [7:0] cg_o_unitvec;
  logic [7:0] cg_i_pkgpw;
  logic [7:0] cg_o_pkgpw;
  logic [7:0] cg_i_pkgmulti;
  logic [7:0] cg_o_pkgmulti;
  logic [7:0] cg_i_pkgbit;
  logic [7:0] cg_o_pkgbit;
  logic cg_i_pkgscalar;
  logic cg_o_pkgscalar;
  logic [7:0] cg_i_varvec;
  logic [7:0] cg_o_varvec;
  logic [7:0] cg_i_pkgvecdim;
  logic [7:0] cg_o_pkgvecdim;
  logic [7:0] cg_i_regvec;
  logic [7:0] cg_o_regvec;
  logic [7:0] cg_i_varpkgvec;
  logic [7:0] cg_o_varpkgvec;
  genvar gi77;
  generate for (gi77 = 0; gi77 < 2; gi77++) begin : gb77
    leaf77d u_gleaf (
    .i_bare(cg_i_bare),
    .i_logicsc(cg_i_logicsc),
    .i_logicvec(cg_i_logicvec),
    .i_wiresc(cg_i_wiresc),
    .i_wirevec(cg_i_wirevec),
    .i_pkgvec(cg_i_pkgvec),
    .i_impvec(cg_i_impvec),
    .i_pkgenum(cg_i_pkgenum),
    .i_impenum(cg_i_impenum),
    .i_pkgstruct(cg_i_pkgstruct),
    .i_impstruct(cg_i_impstruct),
    .i_unitvec(cg_i_unitvec),
    .i_pkgpw(cg_i_pkgpw),
    .i_pkgmulti(cg_i_pkgmulti),
    .i_pkgbit(cg_i_pkgbit),
    .i_pkgscalar(cg_i_pkgscalar),
    .i_varvec(cg_i_varvec),
    .i_pkgvecdim(cg_i_pkgvecdim),
    .i_regvec(cg_i_regvec),
    .i_varpkgvec(cg_i_varpkgvec),
    .o_bare(cg_o_bare),
    .o_logicsc(cg_o_logicsc),
    .o_logicvec(cg_o_logicvec),
    .o_wiresc(cg_o_wiresc),
    .o_wirevec(cg_o_wirevec),
    .o_pkgvec(cg_o_pkgvec),
    .o_impvec(cg_o_impvec),
    .o_pkgenum(cg_o_pkgenum),
    .o_impenum(cg_o_impenum),
    .o_pkgstruct(cg_o_pkgstruct),
    .o_impstruct(cg_o_impstruct),
    .o_unitvec(cg_o_unitvec),
    .o_pkgpw(cg_o_pkgpw),
    .o_pkgmulti(cg_o_pkgmulti),
    .o_pkgbit(cg_o_pkgbit),
    .o_pkgscalar(cg_o_pkgscalar),
    .o_varvec(cg_o_varvec),
    .o_pkgvecdim(cg_o_pkgvecdim),
    .o_regvec(cg_o_regvec),
    .o_varpkgvec(cg_o_varpkgvec)
    );
  end endgenerate
endmodule
module top77;
  mid77 u_mid ();
endmodule
