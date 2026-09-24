import os
C = {}
def c(law, name, body):
    C[(law, name)] = f"// § {law}\n" + body.lstrip('\n')
L='unsignedScalarVecTsAtKeyword137'
c(L,'a01_mod_scalars','''
module top(output logic o);
  reg unsigned r;
  logic unsigned l;
  bit unsigned b;
  assign o = r ^ l ^ b;
endmodule
''')
c(L,'a02_typedef','''
module top(output logic o);
  typedef bit unsigned ub_t;
  typedef logic unsigned ul_t;
  ub_t x;
  ul_t y;
  assign o = x ^ y;
endmodule
''')
c(L,'a03_unpacked_dim','''
module top(output logic o);
  logic unsigned x [3:0];
  bit unsigned y [2];
  assign o = x[0] ^ y[1];
endmodule
''')
c(L,'a04_var_wire','''
module top(output logic o);
  var bit unsigned v;
  wire logic unsigned w;
  assign w = 1'b1;
  assign o = v ^ w;
endmodule
''')
c(L,'a05_init','''
module top(output logic o);
  bit unsigned x = 1'b1;
  logic unsigned y = 1'b0;
  assign o = x ^ y;
endmodule
''')
c(L,'a06_typeparam_default','''
module sub #(parameter type T = bit unsigned)(output logic o);
  T x;
  assign o = x;
endmodule
module top(output logic o);
  sub u(.o(o));
endmodule
''')
c(L,'a07_func_ret_and_local','''
module top(output logic o);
  function automatic bit unsigned f(input bit unsigned a);
    bit unsigned t;
    logic unsigned u;
    t = a; u = t;
    return u;
  endfunction
  assign o = f(1'b1);
endmodule
''')
c(L,'a08_struct_member_union','''
module top(output logic o);
  typedef struct packed { bit unsigned a; logic unsigned b; reg unsigned c; } s_t;
  typedef union packed { bit unsigned a; logic unsigned b; } u_t;
  s_t s; u_t u;
  assign o = s.a ^ u.b;
endmodule
''')
c(L,'a09_nonansi_port','''
module sub(a, b);
  input bit unsigned a;
  output logic unsigned b;
  assign b = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(y));
endmodule
''')
c(L,'a10_ansi_ports_sub','''
module sub(input bit unsigned a, input logic unsigned c, output logic unsigned b);
  assign b = a ^ c;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .c(x), .b(y));
endmodule
''')
c(L,'a11_signed_ctl','''
module top(output logic o);
  bit signed a;
  logic signed b;
  int unsigned c;
  byte unsigned d;
  assign o = a ^ b ^ c[0] ^ d[0];
endmodule
''')
c(L,'a12_task_args_locals','''
module top(output logic o);
  task automatic t(input bit unsigned a, output logic unsigned b);
    reg unsigned q;
    q = a; b = q;
  endtask
  logic r;
  initial t(1'b1, r);
  assign o = r;
endmodule
''')
c(L,'a13_gen_block','''
module top(output logic o);
  if (1) begin : g
    bit unsigned x;
    assign x = 1'b1;
  end
  assign o = g.x;
endmodule
''')
c(L,'a14_pkg_var_and_typedef','''
package p;
  typedef bit unsigned pb_t;
  bit unsigned pv;
endpackage
module top(output logic o);
  p::pb_t x;
  assign o = x ^ p::pv;
endmodule
''')
L='packedArrTdElemRefName137'
c(L,'b01_iface','''
interface bus;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t [3:0] ea_t;
  ea_t v;
endinterface
module top(output logic o);
  bus b();
  assign o = b.v[0][0];
endmodule
''')
c(L,'b02_arr_of_arr','''
module top(output logic o);
  typedef enum logic [1:0] {A, B, C} e_t;
  typedef e_t [1:0] ea_t;
  typedef ea_t [2:0] eaa_t;
  eaa_t v;
  assign o = v[0][0][0];
endmodule
''')
c(L,'b03_pkg_explicit_import','''
package p;
  typedef enum logic [1:0] {A, B} e_t;
  typedef e_t [3:0] ea_t;
endpackage
module top(output logic o);
  import p::ea_t;
  ea_t v;
  assign o = v[1][0];
endmodule
''')
c(L,'b04_scoped_elem','''
package p;
  typedef enum logic [1:0] {A, B} e_t;
endpackage
module top(output logic o);
  typedef p::e_t [3:0] ea_t;
  ea_t v;
  assign o = v[1][0];
endmodule
''')
c(L,'b05_param_of_type','''
module top(output logic o);
  typedef struct packed { logic a; logic b; } s_t;
  typedef s_t [1:0] sa_t;
  parameter sa_t P = '0;
  sa_t v;
  assign o = v[0].a ^ P[1].b;
endmodule
''')
c(L,'b06_sub_two_inst_struct','''
module sub(output logic o);
  typedef struct packed { logic a; logic b; } s_t;
  typedef s_t [1:0] sa_t;
  sa_t v;
  assign v = '1;
  assign o = v[0].a;
endmodule
module top(output logic o1, o2);
  sub u1(.o(o1));
  sub u2(.o(o2));
endmodule
''')
c(L,'b07_func_arg','''
module top(output logic o);
  typedef enum logic {X, Y} e_t;
  typedef e_t [1:0] ea_t;
  function automatic logic f(input ea_t a);
    return a[0];
  endfunction
  ea_t v;
  assign o = f(v);
endmodule
''')
c(L,'b08_pkg_wild_import_two_mods','''
package p;
  typedef struct packed { logic a; } s_t;
  typedef s_t [3:0] sa_t;
endpackage
module sub(output logic o);
  import p::*;
  sa_t w;
  assign o = w[0].a;
endmodule
module top(output logic o);
  import p::*;
  sa_t v;
  sub u(.o());
  assign o = v[2].a;
endmodule
''')
L='emptyNamedConnLowConnAtDecl137'
c(L,'c01_nonansi_vec','''
module sub(a, b, c);
  input [3:0] a;
  output [3:0] b;
  output [3:0] c;
  wire [3:0] c;
  assign b = a; assign c = a;
endmodule
module top(input logic [3:0] x, output logic [3:0] y);
  sub u(.a(x), .b(y), .c(  ));
endmodule
''')
c(L,'c02_comment_inside','''
module sub(input logic a, output logic b, output logic c);
  assign b = a; assign c = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(y), .c(/* open */));
endmodule
''')
c(L,'c03_in_genblock','''
module sub(input logic a, output logic b, output logic c);
  assign b = a; assign c = a;
endmodule
module top(input logic x, output logic y);
  if (1) begin : g
    sub u(.a(x), .b(y), .c());
  end
endmodule
''')
c(L,'c04_inst_array','''
module sub(input logic a, output logic b, output logic c);
  assign b = a; assign c = a;
endmodule
module top(input logic [1:0] x, output logic [1:0] y);
  sub u[1:0] (.a(x), .b(y), .c());
endmodule
''')
c(L,'c05_shared_decl','''
module sub(input logic a, d, output logic b, c);
  assign b = a ^ d; assign c = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .d(), .b(y), .c());
endmodule
''')
c(L,'c06_two_levels','''
module leaf(input logic a, output logic b, output logic c);
  assign b = a; assign c = a;
endmodule
module mid(input logic a, output logic b);
  leaf l(.a(a), .b(b), .c());
endmodule
module top(input logic x, output logic y);
  mid m(.a(x), .b(y));
endmodule
''')
c(L,'c07_explicit_port_expr','''
module sub(.p(q), .r(s));
  input q;
  output s;
  assign s = q;
endmodule
module top(input logic x, output logic y);
  sub u(.p(), .r(y));
endmodule
''')
c(L,'c08_param_sub','''
module sub #(parameter W = 2)(input logic [W-1:0] a, output logic [W-1:0] b, output logic [W-1:0] c);
  assign b = a; assign c = a;
endmodule
module top(input logic [3:0] x, output logic [3:0] y);
  sub #(.W(4)) u(.a(x), .b(y), .c());
endmodule
''')
L='constCallNameSpan137'
c(L,'d01_mod_range_plain','''
module top(output logic o);
  function automatic int f(input int x); return x + 1; endfunction
  logic [f(3)-1:0] v;
  logic [$clog2(8)-1:0] w;
  assign o = v[0] ^ w[0];
endmodule
''')
c(L,'d02_genif_two_qual','''
package q;
  function automatic int w(input int x); return x + 1; endfunction
endpackage
module top(output logic [3:0] o);
  if (q::w(2) + q::w(1) > 3) begin : g
    assign o = 4'd1;
  end else begin : h
    assign o = 4'd2;
  end
endmodule
''')
c(L,'d03_genif_nested_call','''
module top(output logic [3:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  function automatic int g(input int x); return x * 2; endfunction
  if (f(g(1)) == 3) begin : a
    assign o = 4'd1;
  end else begin : b
    assign o = 4'd2;
  end
endmodule
''')
c(L,'d04_gencase','''
module top(output logic [3:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  case (f(2))
    3: begin : a assign o = 4'd1; end
    default: begin : b assign o = 4'd2; end
  endcase
endmodule
''')
c(L,'d05_genfor_bound','''
module top(output logic [3:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  for (genvar i = 0; i < f(3); i++) begin : g
    assign o[i] = 1'b1;
  end
endmodule
''')
c(L,'d06_param_default','''
module sub #(parameter int W = 4)(output logic [W-1:0] o);
  assign o = '0;
endmodule
module top(output logic [3:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  sub #(.W(f(3))) u(.o(o));
endmodule
''')
c(L,'d07_typedef_range_unpacked','''
module top(output logic o);
  function automatic int f(input int x); return x + 1; endfunction
  typedef logic [f(2):0] t_t;
  t_t a;
  logic b [f(1)];
  assign o = a[0] ^ b[0];
endmodule
''')
c(L,'d08_sub_genif_param','''
module sub #(parameter int W = 1)(output logic [3:0] o);
  function automatic int f(input int x); return x + 1; endfunction
  if (f(W) == 3) begin : a
    assign o = 4'd1;
  end else begin : b
    assign o = 4'd2;
  end
endmodule
module top(output logic [3:0] o1, o2);
  sub #(.W(2)) u1(.o(o1));
  sub #(.W(5)) u2(.o(o2));
endmodule
''')
c(L,'d09_genif_call_in_genfor','''
package q;
  function automatic int w(input int x); return x + 1; endfunction
endpackage
module top(output logic [3:0] o);
  for (genvar i = 0; i < 4; i++) begin : l
    if (q::w(i) > 2) begin : a
      assign o[i] = 1'b1;
    end else begin : b
      assign o[i] = 1'b0;
    end
  end
endmodule
''')
c(L,'d10_stmt_ctl','''
package q;
  function automatic int w(input int x); return x + 1; endfunction
endpackage
module top(output int o, output int p);
  function automatic int f(input int x); return x + 1; endfunction
  assign o = f(2) + q::w(3);
  if (1) begin : g
    assign p = q::w(1) + f(1);
  end
endmodule
''')
L='connReplTsRefThroughPort137'
c(L,'e01_repl_in_concat','''
module sub(input logic [7:0] wmask_i, output logic [7:0] o);
  assign o = wmask_i;
endmodule
module top(input logic [3:0] a, output logic [7:0] o);
  sub u_dut(.wmask_i({{4{1'b1}}, a}), .o(o));
endmodule
''')
c(L,'e02_genblock','''
module sub(input logic [7:0] wmask_i, output logic [7:0] o);
  assign o = wmask_i;
endmodule
module top(output logic [7:0] o);
  if (1) begin : g
    sub u_dut(.wmask_i({8{1'b0}}), .o(o));
  end
endmodule
''')
c(L,'e03_param_count','''
module sub #(parameter W = 8)(input logic [W-1:0] wmask_i, output logic [W-1:0] o);
  assign o = wmask_i;
endmodule
module top(output logic [3:0] o);
  localparam N = 4;
  sub #(.W(N)) u_dut(.wmask_i({N{1'b1}}), .o(o));
endmodule
''')
c(L,'e04_two_levels','''
module leaf(input logic [7:0] m, output logic [7:0] o);
  assign o = m;
endmodule
module mid(output logic [7:0] o);
  leaf l(.m({8{1'b1}}), .o(o));
endmodule
module top(output logic [7:0] o);
  mid u(.o(o));
endmodule
''')
c(L,'e05_positional_two','''
module sub(input logic [3:0] a, input logic [3:0] b, output logic [3:0] o);
  assign o = a ^ b;
endmodule
module top(output logic [3:0] o);
  sub u({4{1'b1}}, {2{2'b01}}, o);
endmodule
''')
L='pureVirtProtoSpan137'
c(L,'f01_protected','''
virtual class C;
  pure virtual protected function int f();
  pure virtual protected task t();
endclass
module top(); endmodule
''')
c(L,'f02_iface_class','''
interface class I;
  pure virtual function void f(int a);
  pure virtual task t(int b);
endclass
module top(); endmodule
''')
c(L,'f03_multiline','''
virtual class C;
  pure virtual function
    int f(input int a,
          input int b);
  pure virtual task
    t(input int a);
endclass
module top(); endmodule
''')
c(L,'f04_attr_and_noparens','''
virtual class C;
  (* keep *) pure virtual function int f;
  pure virtual task t;
endclass
module top(); endmodule
''')
c(L,'f05_pkg_class_extends','''
package p;
  virtual class B;
    pure virtual function int f(int x);
  endclass
  class D extends B;
    virtual function int f(int x); return x; endfunction
  endclass
endpackage
module top(); endmodule
''')
c(L,'f06_ret_class_type','''
virtual class C;
  typedef int t_t;
  pure virtual function t_t f();
  pure virtual function C g();
  pure virtual function void h();
endclass
module top(); endmodule
''')
L='taggedUnionElabSpan137'
c(L,'g01_pkg_typedef','''
package p;
  typedef union tagged packed { logic [3:0] a; logic [3:0] b; } u_t;
endpackage
module top(output logic o);
  p::u_t v;
  assign o = v[0];
endmodule
''')
c(L,'g02_member','''
module top(output logic o);
  typedef struct packed { union tagged packed { logic [1:0] a; logic [1:0] b; } u; logic c; } s_t;
  s_t v;
  assign o = v.c;
endmodule
''')
c(L,'g03_two_vars_typedef','''
module top(output logic o);
  typedef union tagged packed { logic [3:0] a; logic [3:0] b; } u_t;
  u_t v, w;
  union tagged packed { logic [1:0] x; logic [1:0] y; } z;
  assign o = v[0] ^ w[1] ^ z[0];
endmodule
''')
L='defNetTypeParamDefault137'
c(L,'h01_two_nets_dims','''
module bottom #(parameter type TP1 = logic);
  TP1 A [3:0];
  TP1 B [1:0];
endmodule
module top ();
  bottom #(.TP1(int)) u2();
endmodule
''')
c(L,'h02_net_and_port','''
module bottom #(parameter type TP1 = logic)(input TP1 i, output TP1 o);
  TP1 t;
  assign t = i;
  assign o = t;
endmodule
module top (input logic a, output logic b);
  bottom u(.i(a), .o(b));
endmodule
''')
c(L,'h03_packed_default','''
module bottom #(parameter type T = logic [7:0])(output logic o);
  T d;
  assign o = d[0];
endmodule
module top (output logic o1, o2);
  bottom u1(.o(o1));
  bottom #(.T(logic [3:0])) u2(.o(o2));
endmodule
''')
c(L,'h04_struct_default','''
package p;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module bottom #(parameter type T = p::s_t)(output logic o);
  T d;
  assign o = d.a;
endmodule
module top (output logic o);
  bottom u(.o(o));
endmodule
''')
c(L,'h05_genblock_net','''
module bottom #(parameter type T = logic)(output logic o);
  if (1) begin : g
    T d;
    assign d = 1'b1;
  end
  assign o = g.d;
endmodule
module top (output logic o);
  bottom u(.o(o));
endmodule
''')
c(L,'h06_init_and_var','''
module bottom #(parameter type T = logic)(output logic o);
  T d = 1'b1;
  var T v;
  assign v = d;
  assign o = v;
endmodule
module top (output logic o);
  bottom u(.o(o));
endmodule
''')
c(L,'h07_two_insts_overrides','''
module bottom #(parameter type T = logic)(output logic o);
  T d;
  assign d = '1;
  assign o = d[0];
endmodule
module top (output logic o1, o2, o3);
  bottom #(.T(int)) u1(.o(o1));
  bottom #(.T(byte)) u2(.o(o2));
  bottom u3(.o(o3));
endmodule
''')
c(L,'h08_wire_kw','''
module bottom #(parameter type T = logic)(output logic o);
  wire T w;
  assign w = 1'b1;
  assign o = w;
endmodule
module top (output logic o);
  bottom u(.o(o));
endmodule
''')
L='aliasCloneTakesTargetFile137'
c(L,'i01_two_aliases','''
package pkg;
  typedef struct packed { logic x; } a;
  typedef a b[5:0];
  typedef a c[3:0];
endpackage
module dut(output o);
  pkg::b u;
  pkg::c v;
  assign u[0].x = 1;
  assign v[0].x = 1;
  assign o = u[0].x ^ v[1].x;
endmodule
''')
c(L,'i02_enum_union','''
module dut(output o);
  typedef enum logic {X, Y} e;
  typedef e ea [2];
  typedef union packed { logic a; logic b; } u;
  typedef u ua [3];
  ea p;
  ua q;
  assign o = q[0].a;
endmodule
''')
c(L,'i03_include_target','''
`include "s.svh"
module dut(output o);
  typedef s_t sa [2];
  sa v;
  assign v[0].x = 1'b1;
  assign o = v[0].x;
endmodule
''')
L='defNetScopedPkgArrTdShares137'
c(L,'j01_two_nets','''
package pkg;
  typedef struct packed { logic x; } a;
  typedef a b[5:0];
endpackage
module dut(output o);
  pkg::b c;
  pkg::b d;
  assign c[1].x = 1;
  assign d[2].x = 0;
  assign o = c[1].x ^ d[2].x;
endmodule
''')
c(L,'j02_logic_vec_elem','''
package pkg;
  typedef logic [3:0] b [2];
endpackage
module dut(output o);
  pkg::b c;
  assign c[0] = 4'd1;
  assign o = c[0][0];
endmodule
''')
c(L,'j03_2d','''
package pkg;
  typedef struct packed { logic x; } a;
  typedef a b [2][3];
endpackage
module dut(output o);
  pkg::b c;
  assign c[1][2].x = 1;
  assign o = c[1][2].x;
endmodule
''')
c(L,'j04_arr_of_arr_td','''
package pkg;
  typedef logic [1:0] a;
  typedef a b [2];
  typedef b cc [3];
endpackage
module dut(output o);
  pkg::cc x;
  assign x[0][1] = 2'd1;
  assign o = x[0][1][0];
endmodule
''')
c(L,'j05_iface','''
package pkg;
  typedef struct packed { logic x; } a;
  typedef a b[5:0];
endpackage
interface bus;
  pkg::b c;
endinterface
module dut(output o);
  bus i();
  assign o = i.c[0].x;
endmodule
''')
c(L,'j06_genblock','''
package pkg;
  typedef struct packed { logic x; } a;
  typedef a b[5:0];
endpackage
module dut(output o);
  if (1) begin : g
    pkg::b c;
    assign c[1].x = 1;
  end
  assign o = g.c[1].x;
endmodule
''')
c(L,'j07_sub_two_inst','''
package pkg;
  typedef struct packed { logic x; } a;
  typedef a b[5:0];
endpackage
module sub(output o);
  pkg::b c;
  assign c[1].x = 1;
  assign o = c[1].x;
endmodule
module dut(output o1, o2);
  sub u1(.o(o1));
  sub u2(.o(o2));
endmodule
''')
c(L,'j08_queue_ctl','''
package pkg;
  typedef int b[$];
  typedef int d[];
endpackage
module dut(output int o);
  pkg::b c;
  pkg::d e;
  initial begin c.push_back(1); o = c[0]; end
endmodule
''')
L='structParamPathBaseAtMember137'
c(L,'k01_gencase','''
package p;
  typedef struct packed { int MODE; int W; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{MODE: 1, W: 4})(output logic o);
  case (CFG.MODE)
    1: begin : a assign o = 1'b1; end
    default: begin : b assign o = 1'b0; end
  endcase
endmodule
''')
c(L,'k02_genfor_bound','''
package p;
  typedef struct packed { int N; int W; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{N: 3, W: 4})(output logic [3:0] o);
  for (genvar i = 0; i < CFG.N; i++) begin : g
    assign o[i] = 1'b1;
  end
endmodule
''')
c(L,'k03_sub_override','''
package p;
  typedef struct packed { int DAT; int ADR; } cfg_t;
endpackage
module sub #(parameter p::cfg_t CFG = '{DAT: 8, ADR: 4})(output logic o);
  logic [CFG.DAT-1:0] d;
  if (CFG.ADR > 2) begin : g
    assign d = '1;
  end
  assign o = d[0];
endmodule
module top(output logic o1, o2);
  sub #(.CFG('{DAT: 16, ADR: 2})) u1(.o(o1));
  sub u2(.o(o2));
endmodule
''')
c(L,'k04_localparam_struct','''
module top(output logic o);
  typedef struct packed { int W; int N; } cfg_t;
  localparam cfg_t C = '{W: 5, N: 2};
  logic [C.W-1:0] x;
  logic y [C.N];
  assign o = x[0] ^ y[0];
endmodule
''')
c(L,'k05_two_paths_in_range','''
package p;
  typedef struct packed { int A; int B; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{A: 3, B: 2})(output logic o);
  logic [CFG.A+CFG.B-1:0] x;
  assign o = x[0];
endmodule
''')
c(L,'k06_nested_genif_in_genfor','''
package p;
  typedef struct packed { int E; int N; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{E: 1, N: 2})(output logic [1:0] o);
  for (genvar i = 0; i < 2; i++) begin : l
    if (CFG.E == 1) begin : a
      assign o[i] = 1'b1;
    end else begin : b
      assign o[i] = 1'b0;
    end
  end
endmodule
''')
c(L,'k07_sys_call_in_range','''
package p;
  typedef struct packed { int D; int W; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{D: 16, W: 4})(output logic o);
  logic [$clog2(CFG.D)-1:0] x;
  assign o = x[0];
endmodule
''')
c(L,'k08_port_named_like_param_elsewhere','''
package p;
  typedef struct packed { int W; } cfg_t;
endpackage
interface bus #(parameter int W = 2);
  logic [W-1:0] d;
endinterface
module sub #(parameter p::cfg_t CFG = '{W: 4})(bus CFGB, output logic o);
  logic [CFG.W-1:0] x;
  assign o = x[0] ^ CFGB.d[0];
endmodule
module top(output logic o);
  bus b();
  sub u(.CFGB(b), .o(o));
endmodule
''')
c(L,'k09_three_level_genif','''
package p;
  typedef struct packed { int W; } in_t;
  typedef struct packed { in_t I; int X; } cfg_t;
endpackage
module top #(parameter p::cfg_t CFG = '{I: '{W: 4}, X: 1})(output logic o);
  if (CFG.I.W > 2) begin : g
    assign o = 1'b1;
  end else begin : h
    assign o = 1'b0;
  end
endmodule
''')
L='elabCloneFullNameUnstored137'
c(L,'l01_sub_genblock_always','''
module dut(input logic a, output logic b);
  if (1) begin : g
    logic t;
    always_comb begin
      t = a;
    end
    assign b = t;
  end
endmodule
module top(input logic x, output logic y1, y2);
  dut u1(.a(x), .b(y1));
  dut u2(.a(x), .b(y2));
endmodule
''')
c(L,'l02_iface_proc_func','''
interface bus(input logic clk);
  logic d, q;
  function automatic logic inv(input logic v);
    logic t;
    t = ~v;
    return t;
  endfunction
  always_ff @(posedge clk) q <= inv(d);
endinterface
module top(input logic clk, output logic o);
  bus b(.clk(clk));
  assign o = b.q;
endmodule
''')
c(L,'l03_three_levels','''
module leaf(input logic a, output logic b);
  function automatic logic f(input logic v);
    logic t;
    t = v;
    return t;
  endfunction
  always_comb b = f(a);
endmodule
module mid(input logic a, output logic b);
  leaf l(.a(a), .b(b));
endmodule
module top(input logic x, output logic y);
  mid m(.a(x), .b(y));
endmodule
''')
c(L,'l04_pkg_func_two_mods','''
package pk;
  function automatic int add(input int a, input int b);
    int s;
    s = a + b;
    return s;
  endfunction
endpackage
module sub(output int o);
  assign o = pk::add(1, 2);
endmodule
module top(output int o, output int p);
  sub u(.o(o));
  assign p = pk::add(3, 4);
endmodule
''')
c(L,'l05_named_block_task','''
module dut(input logic a, output logic b);
  task automatic t(input logic v, output logic w);
    logic z;
    z = v;
    w = z;
  endtask
  always_comb begin : blk
    logic loc;
    t(a, loc);
    b = loc;
  end
endmodule
module top(input logic x, output logic y);
  dut u(.a(x), .b(y));
endmodule
''')
c(L,'l06_cont_assign_hier','''
module dut(input logic [3:0] a, output logic [3:0] b);
  wire [3:0] w = a + 4'd1;
  assign b = w[3:0];
endmodule
module top(input logic [3:0] x, output logic [3:0] y);
  dut u(.a(x), .b(y));
endmodule
''')
c(L,'l07_gen_for_sub','''
module dut(input logic a, output logic b);
  always_comb b = a;
endmodule
module top(input logic [1:0] x, output logic [1:0] y);
  for (genvar i = 0; i < 2; i++) begin : g
    dut u(.a(x[i]), .b(y[i]));
  end
endmodule
''')
L='caLhsDefNetUnlessOpRhs139'
c(L,'m01_param_rhs_two_inst','''
module sub #(parameter logic [3:0] P = 4'd1)(output logic [3:0] y);
  assign y = P;
endmodule
module top(output logic [3:0] a, b);
  sub #(.P(4'd2)) u1(.y(a));
  sub u2(.y(b));
endmodule
''')
c(L,'m02_func_rhs','''
module sub(input logic [3:0] a, output logic [3:0] y, output logic [3:0] z);
  function automatic logic [3:0] f(input logic [3:0] v); return ~v; endfunction
  assign y = f(a);
  assign z = a;
endmodule
module top(input logic [3:0] x, output logic [3:0] a, b);
  sub u(.a(x), .y(a), .z(b));
endmodule
''')
c(L,'m03_concat_lhs_and_select','''
module sub(input logic [3:0] a, output logic [1:0] y, output logic [1:0] z, output logic [3:0] w);
  assign {y, z} = a;
  assign w[0] = a[0];
  assign w[3:1] = a[3:1] & 3'b101;
endmodule
module top(input logic [3:0] x, output logic [1:0] a, b, output logic [3:0] c);
  sub u(.a(x), .y(a), .z(b), .w(c));
endmodule
''')
L='ndaLeftmostLeafElab139'
c(L,'m04_nda_ternary_unary','''
module sub(input logic s, input logic a, input logic b, output logic y, output logic z);
  wire t = s ? a : b;
  wire u = ~a & b;
  assign y = t;
  assign z = u;
endmodule
module top(input logic s, a, b, output logic y, z);
  sub u(.s(s), .a(a), .b(b), .y(y), .z(z));
endmodule
''')
c(L,'m05_nda_bitsel_idx','''
module sub(input logic [3:0] a, input logic [1:0] i, output logic y);
  wire t = a[i] ^ a[0];
  assign y = t;
endmodule
module top(input logic [3:0] a, input logic [1:0] i, output logic y);
  sub u(.a(a), .i(i), .y(y));
endmodule
''')
L='connLeftmostLeafElab139'
c(L,'m06_conn_ops_genblock','''
module sub(input logic a, output logic b);
  assign b = a;
endmodule
module top(input logic p, q, r, output logic y1, y2);
  sub u1(.a(p & q | r), .b(y1));
  if (1) begin : g
    sub u2(.a(q ^ r), .b(y2));
  end
endmodule
''')
c(L,'m07_conn_ternary_select','''
module sub(input logic a, output logic b);
  assign b = a;
endmodule
module top(input logic s, input logic [3:0] v, output logic y1, y2);
  sub u1(.a(s ? v[1] : v[2]), .b(y1));
  sub u2(.a(v[s] & v[0]), .b(y2));
endmodule
''')
L='clockingEventDefNet139'
c(L,'m08_clk_two_inst_param','''
module sub #(parameter int W = 1)(input logic clk, input logic [W-1:0] d, output logic [W-1:0] q);
  default clocking cb @(posedge clk); endclocking
  always_ff @(posedge clk) q <= d;
endmodule
module top(input logic clk, input logic [3:0] d, output logic [3:0] q1, output logic q2);
  sub #(.W(4)) u1(.clk(clk), .d(d), .q(q1));
  sub u2(.clk(clk), .d(d[0]), .q(q2));
endmodule
''')
c(L,'m09_clk_negedge_iff','''
module top(input logic clk, input logic rst, input logic d, output logic q);
  default clocking cb @(negedge clk iff !rst); endclocking
  always_ff @(negedge clk) q <= d;
endmodule
''')
for (law, name), txt in C.items():
    d = os.path.join('cases', name)
    os.makedirs(d, exist_ok=True)
    open(os.path.join(d, 'dut.sv'), 'w').write(txt)
open('cases/i03_include_target/s.svh','w').write("typedef struct packed {\n  logic x;\n} s_t;\n")
print(len(C))
