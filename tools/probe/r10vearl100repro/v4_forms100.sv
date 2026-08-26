// v100 arm 4 — declaration FORMS: unpacked struct, unpacked array of structs,
// wire/var of struct type, initializers, local vs package typedef, and a
// non-ANSI port declaration — all inside modules that trigger the route.
package vp4;
  typedef struct packed   { logic [7:0] a; logic [7:0] b; } pk_t;
  typedef struct          { logic [7:0] a; logic [7:0] b; } up_t;   // unpacked, all logic
  typedef enum logic { Q0, Q1 } q_t;
  typedef struct          { logic [7:0] a; q_t     b; }     upv_t;  // unpacked, enum member
endpackage

// non-ANSI port list, blocking write to a struct port -> route fires
module v4_nonansi import vp4::*; (p, q, o);

  input  pk_t p;
  output pk_t q;
  output logic [7:0] o;
  always_comb q = p;
  assign o = p.a;
endmodule

// unpacked struct port + unpacked array of packed struct port, undriven
module v4_unp import vp4::*; (input up_t up, input upv_t upv, input pk_t arr [0:1],
               output logic [7:0] o);
  assign o = up.a ^ upv.a ^ arr[0].a ^ arr[1].b;
endmodule

module v4_forms100 import vp4::*; ();

  pk_t   d_plain;
  wire   pk_t d_wire;
  var    pk_t d_var;
  pk_t   d_pat  = '{a:8'h1, b:8'h2};
  pk_t   d_zero = '0;
  pk_t   d_cat  = {8'h3, 8'h4};
  pk_t   d_arr [0:1];
  up_t   d_unp;
  upv_t  d_unpv;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } loc_t;
  loc_t  d_loc;
  pk_t   s_in, s_out;
  logic [7:0] o1, o2;
  v4_nonansi u_na (.p(s_in), .q(s_out), .o(o1));
  v4_unp     u_up (.up(d_unp), .upv(d_unpv), .arr(d_arr), .o(o2));
  assign s_in   = '0;
  assign d_plain = '0;
  assign d_wire  = '0;
  assign d_loc   = '0;
endmodule
