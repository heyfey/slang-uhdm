// r10v88 v1 — ADVERSARIAL: the MEMBER-TYPE axis of the STRICT scan.
// MEASUREMENT ONLY.
package r88;
  parameter int NP = 2;
  typedef logic [7:0]  v8_t;
  typedef v8_t         v8a_t;          // typedef of typedef (logic)
  typedef bit  [7:0]   b8_t;
  typedef enum logic [1:0] { RA, RB } e_t;
  typedef struct packed { logic q; } inner_t;
  typedef union  packed { logic [3:0] u; logic [3:0] v; } pu_t;

  // ---- element structs, one member axis each ----
  typedef struct packed { logic a; logic [3:0] b; }      m_plain_t;   // ctrl: all plain logic
  typedef struct packed { logic a; v8_t v; }             m_tdlog_t;   // typedef'd logic member
  typedef struct packed { logic a; v8a_t v; }            m_td2log_t;  // typedef-of-typedef logic
  typedef struct packed { logic a; logic signed [3:0] s; } m_signed_t; // signed logic member
  typedef struct packed { logic a; inner_t i; }          m_tdstr_t;   // typedef'd STRUCT member
  typedef struct packed { logic a; pu_t u; }             m_punion_t;  // packed UNION member
  typedef struct packed { logic a; e_t e; }              m_enum_t;    // enum member
  typedef struct packed { logic a; b8_t b; }             m_tdbit_t;   // typedef'd bit member
  typedef struct packed { logic [NP-1:0] p; }            m_parmdim_t; // param-bounded member
  typedef struct packed { logic a; }                     m_one_t;     // single member
  typedef struct packed { logic a; logic [1:0][2:0] c; } m_2dlog_t;   // 2-D logic member

  typedef m_plain_t   ma_plain_t;   // ALIAS of an all-logic struct
  typedef m_tdstr_t   ma_tdstr_t;   // ALIAS of a struct-member struct
endpackage

package r88b;
  typedef struct packed { logic z; } other_t;
endpackage

package r88c;
  import r88b::*;
  typedef struct packed { logic a; r88b::other_t o; } m_xpkg_t; // member from ANOTHER package
endpackage

module vleaf1 (
  input  r88::m_plain_t   [1:0] i_plain,   output r88::m_plain_t   [1:0] o_plain,
  input  r88::m_tdlog_t   [1:0] i_tdlog,   output r88::m_tdlog_t   [1:0] o_tdlog,
  input  r88::m_td2log_t  [1:0] i_td2log,  output r88::m_td2log_t  [1:0] o_td2log,
  input  r88::m_signed_t  [1:0] i_signed,  output r88::m_signed_t  [1:0] o_signed,
  input  r88::m_tdstr_t   [1:0] i_tdstr,   output r88::m_tdstr_t   [1:0] o_tdstr,
  input  r88::m_punion_t  [1:0] i_punion,  output r88::m_punion_t  [1:0] o_punion,
  input  r88::m_enum_t    [1:0] i_enum,    output r88::m_enum_t    [1:0] o_enum,
  input  r88::m_tdbit_t   [1:0] i_tdbit,   output r88::m_tdbit_t   [1:0] o_tdbit,
  input  r88::m_parmdim_t [1:0] i_parmdim, output r88::m_parmdim_t [1:0] o_parmdim,
  input  r88::m_one_t     [1:0] i_one,     output r88::m_one_t     [1:0] o_one,
  input  r88::m_2dlog_t   [1:0] i_2dlog,   output r88::m_2dlog_t   [1:0] o_2dlog,
  input  r88::ma_plain_t  [1:0] i_aplain,  output r88::ma_plain_t  [1:0] o_aplain,
  input  r88::ma_tdstr_t  [1:0] i_atdstr,  output r88::ma_tdstr_t  [1:0] o_atdstr,
  input  r88c::m_xpkg_t   [1:0] i_xpkg,    output r88c::m_xpkg_t   [1:0] o_xpkg,
  input  r88::pu_t        [1:0] i_pu,      output r88::pu_t        [1:0] o_pu,
  // the SAME element types with NO written packed dims (the LOOSE arm must not move)
  input  r88::m_tdlog_t         i_tdlog_d0,
  input  r88::m_tdstr_t         i_tdstr_d0,
  input  r88::m_punion_t        i_punion_d0,
  input  r88::ma_tdstr_t        i_atdstr_d0
);
endmodule

module vtop1;
  r88::m_plain_t   [1:0] w_plain;
  r88::m_tdlog_t   [1:0] w_tdlog;
  r88::m_tdstr_t   [1:0] w_tdstr;
  r88::m_punion_t  [1:0] w_punion;
  r88::ma_plain_t  [1:0] w_aplain;
  r88::ma_tdstr_t  [1:0] w_atdstr;
  r88c::m_xpkg_t   [1:0] w_xpkg;
  r88::m_signed_t  [1:0] w_signed;
  r88::m_2dlog_t   [1:0] w_2dlog;
  r88::m_tdlog_t         w_tdlog_d0;
  r88::m_tdstr_t         w_tdstr_d0;
  r88::m_plain_t   [1:0] w_plain2;
  vleaf1 u1 ();                       // undriven instance
  vleaf1 u2 (.i_plain(w_plain), .o_plain(w_plain2),
             .i_tdlog(w_tdlog), .i_tdstr(w_tdstr),
             .i_punion(w_punion), .i_aplain(w_aplain),
             .i_atdstr(w_atdstr), .i_xpkg(w_xpkg),
             .i_signed(w_signed), .i_2dlog(w_2dlog),
             .i_tdlog_d0(w_tdlog_d0), .i_tdstr_d0(w_tdstr_d0));
endmodule
