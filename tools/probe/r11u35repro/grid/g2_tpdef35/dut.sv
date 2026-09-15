// r11u35 g2_tpdef35 — a TYPE PARAMETER's DECLARATION DEFAULT whose default is
// an ANONYMOUS AGGREGATE: do the MEMBER dimensions take the `Reduce::No` of
// `CompileHelper::compileParameterDeclaration` the way the parameter's own
// packed dims already do (§ typeParamDefaultBoundNoReduce20)?
// The corpus face is `localparam type it_t = struct packed
// { logic [Cfg.XLEN-1:0] x; }` (cva6_struct_param_field / StructParamFieldRange).
package g2pk35;
  typedef struct packed {
    int unsigned XLEN;
    int unsigned VLEN;
  } cfg_t;
  localparam cfg_t DefaultCfg = '{XLEN: 32'd64, VLEN: 32'd64};
  parameter int unsigned PU = 5;
  // A package-scope type parameter with an anonymous-struct default.
  parameter type pk_tp_t = struct packed { logic [PU-1:0] a; };
endpackage

interface g2if35 #(parameter int unsigned IU = 6) ();
  localparam type if_tp_t = struct packed { logic [IU-1:0] a; };
  if_tp_t iv;
endinterface

module g2sub35 #(
    parameter g2pk35::cfg_t Cfg = g2pk35::DefaultCfg,
    parameter int unsigned  NU  = 5,
    // an ANSI type parameter whose default is an anonymous struct
    parameter type          ANSI_T = struct packed { logic [NU-1:0] a; }
) ();
  // the corpus shape: a HIER-PATH member read in the member dim
  localparam type hp_t = struct packed {
    logic [Cfg.XLEN-1:0] x;
    logic [Cfg.XLEN-1:0] y;
  };
  // a plain PARAM-REF operation member dim
  localparam type op_t = struct packed { logic [NU-1:0] a; };
  // a BARE NAME member dim
  localparam type bare_t = struct packed { logic [NU:0] a; };
  // a LITERAL member dim (control)
  localparam type lit_t = struct packed { logic [7:0] a; };
  // a NESTED anonymous struct
  localparam type nest_t = struct packed {
    struct packed { logic [NU-1:0] inner; } n;
    logic [NU-1:0] o;
  };
  // an anonymous UNION
  localparam type uni_t = union packed { logic [NU-1:0] a; logic [NU-1:0] b; };
  // an anonymous ENUM whose base carries the bound
  localparam type enu_t = enum logic [NU-1:0] { E0, E1 };
  // an UNPACKED-array member dim
  localparam type arr_t = struct packed { logic [NU-1:0][1:0] a; };
  // a NAMED struct as the default (the named typedef's own rule owns it)
  typedef struct packed { logic [NU-1:0] a; } named_s_t;
  localparam type nm_t = named_s_t;
  // a KEYWORD default with dims (the landed § 20 arm — control, already equal)
  localparam type kw_t = logic [NU-1:0];

  hp_t   s_hp;
  op_t   s_op;
  bare_t s_bare;
  lit_t  s_lit;
  nest_t s_nest;
  uni_t  s_uni;
  enu_t  s_enu;
  arr_t  s_arr;
  nm_t   s_nm;
  kw_t   s_kw;
  ANSI_T s_ansi;
  g2pk35::pk_tp_t s_pk;
endmodule

module g2_tpdef35 ();
  g2sub35 #() u_def ();
  // an OVERRIDDEN type parameter: the override's type is compiled during
  // ELABORATION and folds (the other half of § 20).  slang REFUSES an
  // anonymous aggregate written inline in an override ("missing '(' in
  // parameter list"), and an arm whose compile fails teaches error recovery,
  // not golden — so the override names a typedef, the corpus's own shape.
  typedef struct packed { logic [3:0] a; } ov_s_t;
  g2sub35 #(.ANSI_T(ov_s_t)) u_ov ();
  g2if35 #() u_if ();
endmodule
