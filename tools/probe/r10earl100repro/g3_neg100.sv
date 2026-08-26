// r10earl100 ARM g3 — NEGATIVE CONTROLS.  Shapes § structPortNetIsMemberScanOnly100
// must NOT move: they must be BYTE-IDENTICAL on the pristine and patched
// binaries.  MEASUREMENT ONLY.
package gp3;
  typedef enum logic [1:0] { C0, C1 } ce_t;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } n3_t;
  typedef struct packed { logic [3:0] a; ce_t e; }        v3_t;
  function automatic n3_t mk3(logic [3:0] x);
    n3_t r;              // a struct LOCAL of a package function
    r.a = x; r.b = ~x;
    return r;
  endfunction
endpackage

class c3 #(type T = gp3::n3_t);
  T          m_s;        // a struct CLASS PROPERTY
  gp3::v3_t  m_v;
  function new(); m_s = '0; m_v = '0; endfunction
endclass

// a struct-typed port whose typedef is LOCAL to the module (not a package)
module g3_loctd (input logic i, output logic o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } lp_t;
  lp_t lb;
  assign lb = {i,i,i,i,i,i,i,i};
  assign o = ^lb;
endmodule

module g3_init import gp3::*; (input logic i, output logic o);
  n3_t s_pat  = '{a:4'h1, b:4'h2};    // structured pattern init
  n3_t s_pos  = '{4'h3, 4'h4};        // positional pattern init
  n3_t s_lit  = '0;                   // unbased-unsized literal init
  v3_t v_pat  = '{a:4'h5, e:C1};      // pattern init on a VAR-kind struct
  assign o = ^{s_pat, s_pos, s_lit, v_pat, i};
endmodule

module g3_local (input logic i, output logic o);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } loc_t;  // LOCAL typedef
  loc_t l;
  assign l = {i,i,i,i,i,i,i,i};
  assign o = ^l;
endmodule

module g3_task import gp3::*; (input logic i, output logic o);
  logic r;
  function automatic logic f3(logic x);
    n3_t t;              // a struct local of a MODULE function
    t.a = {4{x}}; t.b = '0;
    return ^t;
  endfunction
  always_comb begin
    n3_t bs;             // a struct local of an always_comb BLOCK
    bs = mk3({4{i}});
    r = ^bs ^ f3(i);
  end
  assign o = r;
endmodule

module g3_top import gp3::*; (input logic c, output logic o);
  logic o1,o2,o3,o4;
  g3_loctd u1 (.i(c), .o(o1));
  g3_init  u3 (.i(c), .o(o3));
  g3_local u4 (.i(c), .o(o4));
  g3_task  u5 (.i(c), .o(o2));
  assign o = o1 ^ o2 ^ o3 ^ o4;
endmodule
