// r10earl100 ARM a1 — BARE vs pkg::-QUALIFIED x the member scan.  MEASUREMENT ONLY.
package p100;
  typedef enum logic [1:0] { E0, E1 } e_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } all_logic_t;
  typedef struct packed { logic [3:0] a; e_t e; }         has_enum_t;
  typedef struct packed { all_logic_t inner; logic c; }   has_struct_t;
  typedef logic [7:0] byte_t;
  typedef struct packed { byte_t a; logic [3:0] b; }      via_typedef_t;
endpackage

module sub_bare import p100::*; (
  input  all_logic_t   pi_all,
  input  has_enum_t    pi_enum,
  input  has_struct_t  pi_struct,
  input  via_typedef_t pi_vtd,
  output logic         o
);
  all_logic_t   b_all;
  has_enum_t    b_enum;
  has_struct_t  b_struct;
  via_typedef_t b_vtd;
  assign b_all = pi_all;
  assign b_enum = pi_enum;
  assign b_struct = pi_struct;
  assign b_vtd = pi_vtd;
  assign o = ^{b_all, b_enum, b_struct, b_vtd};
endmodule

module sub_qual (
  input  p100::all_logic_t   pi_all,
  input  p100::has_enum_t    pi_enum,
  input  p100::has_struct_t  pi_struct,
  input  p100::via_typedef_t pi_vtd,
  output logic               o
);
  p100::all_logic_t   b_all;
  p100::has_enum_t    b_enum;
  p100::has_struct_t  b_struct;
  p100::via_typedef_t b_vtd;
  assign b_all = pi_all;
  assign b_enum = pi_enum;
  assign b_struct = pi_struct;
  assign b_vtd = pi_vtd;
  assign o = ^{b_all, b_enum, b_struct, b_vtd};
endmodule

module top100 import p100::*; (input all_logic_t t_all, output logic o1, output logic o2);
  all_logic_t   w_all;
  has_enum_t    w_enum;
  has_struct_t  w_struct;
  via_typedef_t w_vtd;
  assign w_all = t_all;
  sub_bare u_bare (.pi_all(w_all), .pi_enum(w_enum), .pi_struct(w_struct), .pi_vtd(w_vtd), .o(o1));
  sub_qual u_qual (.pi_all(w_all), .pi_enum(w_enum), .pi_struct(w_struct), .pi_vtd(w_vtd), .o(o2));
endmodule
