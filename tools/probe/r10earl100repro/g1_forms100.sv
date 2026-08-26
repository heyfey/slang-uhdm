// r10earl100 ARM g1 — DECLARATION FORMS x the member scan.  MEASUREMENT ONLY.
package gp1;
  typedef enum logic [1:0] { A0, A1 } en_t;
  typedef logic [7:0] byte8_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; }   netlike_t;   // all logic  -> NET
  typedef struct packed { netlike_t n; logic c; }           nested_t;    // struct mem -> NET
  typedef struct packed { byte8_t v; logic [1:0] w; }       viatd_t;     // typedef mem-> NET
  typedef struct packed { logic [3:0] a; en_t e; }          enummem_t;   // enum mem   -> VAR
  typedef struct packed { logic [1:0][3:0] p; logic c; }    parrmem_t;   // parr mem   -> VAR
  typedef struct packed { bit [3:0] a; logic [3:0] b; }     bitmem_t;    // bit  mem   -> VAR
endpackage

module g1_forms import gp1::*; (
  input  netlike_t  p_net_bare,          // bare pkg struct, net-like  -> struct_net
  input  gp1::netlike_t p_net_qual,      // pkg::-qualified, net-like  -> struct_net
  input  enummem_t  p_var_bare,          // bare, enum member          -> struct_var
  input  nested_t   p_nest,
  input  viatd_t    p_vtd,
  input  parrmem_t  p_parr,
  input  bitmem_t   p_bit,
  input  logic      i,
  output logic      o
);
  logic     d_logic;                      // a plain logic body decl
  netlike_t d_plain;                      // struct-typed body decl
  var netlike_t d_varkw;                  // `var` keyword
  wire netlike_t d_wire;                  // `wire` of struct type
  struct packed { logic [3:0] a; logic [3:0] b; } d_anon;  // anonymous packed struct
  netlike_t d_uarr [2];                   // unpacked array of struct
  netlike_t [1:0] d_parr;                 // packed array of struct
  enummem_t d_evar;                       // struct with an enum member
  nested_t  d_nest;
  assign d_logic = i;
  assign d_plain = {d_logic, p_net_bare.a, p_net_bare.b[2:0]};
  assign d_wire  = d_plain;
  assign d_anon  = d_plain;
  assign d_nest  = p_nest;
  assign o = ^{d_logic, d_plain, d_varkw, d_wire, d_anon, d_uarr[0], d_uarr[1],
               d_parr, d_evar, d_nest, p_net_bare, p_net_qual, p_var_bare,
               p_vtd, p_parr, p_bit};
endmodule

module g1_top import gp1::*; (input logic c, output logic o);
  netlike_t s_net; enummem_t s_ev; nested_t s_nd; viatd_t s_vt;
  parrmem_t s_pm; bitmem_t s_bm;
  g1_forms u_f (.p_net_bare(s_net), .p_net_qual(s_net), .p_var_bare(s_ev),
                .p_nest(s_nd), .p_vtd(s_vt), .p_parr(s_pm), .p_bit(s_bm),
                .i(c), .o(o));
endmodule
