# v11u275 mkcases.py: writes every case under ../cases (VK = the VN cases of § defNetTpPatKeepsActual275v).
import os
R=os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'cases')
L={'VK':'defNetTpPatKeepsActual275v','VV':'tpTypedVarInitNameSpan275','VA':'tfLocalArrRangeDimEnd275','VI':'importNetTsDimEnd275',
   'VG':'ifaceGenCaLhsUnbound275','VP':'tpPackedArrCaUnparent275','VN':'defNetTpDimLastInstPat275'}
C={}
def c(g,n,desc,body,crlf=False):
    gd='VN' if g=='VK' else g
    d=os.path.join(R,gd,n); os.makedirs(d,exist_ok=True)
    t='// § %s — %s\n'%(L[g],desc)+body.lstrip('\n')
    if crlf: t=t.replace('\n','\r\n')
    open(os.path.join(d,'dut.sv'),'w',newline='').write(t)
# ---- VV: type-parameter typed variable with an initializer
c('VV','vv01_anon_struct_tp','anonymous packed struct type parameter, initializer',r'''
module dut #(parameter type T = struct packed { logic [1:0] a; logic [1:0] b; }) (output logic [3:0] o);
  T x = 4'h9;
  assign o = x;
endmodule
''')
c('VV','vv02_two_declarators','two declarators with initializers',r'''
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o, output logic [3:0] p);
  T x = 4'h5, y = 4'ha;
  assign o = x;
  assign p = y;
endmodule
''')
c('VV','vv03_var_by_macro','a var keyword produced by a macro',r'''
`define VK var
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o);
  `VK T x = 4'h5;
  assign o = x;
endmodule
''')
c('VV','vv04_var_comment_semi','a var declaration whose preceding text holds a semicolon in a comment',r'''
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o);
  var /* ; */ T x = 4'h5;
  assign o = x;
endmodule
''')
c('VV','vv05_genblock','a type-parameter variable with an initializer inside a generate block',r'''
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o);
  if (1) begin : g
    T x = 4'h3;
    assign o = x;
  end
endmodule
''')
c('VV','vv06_iface','a type-parameter variable with an initializer inside an interface',r'''
interface ifc #(parameter type T = logic [3:0]) ();
  T x = 4'h6;
endinterface
module dut (output logic [3:0] o);
  ifc u ();
  assign o = u.x;
endmodule
''')
c('VV','vv07_scalar_logic','a scalar logic type parameter',r'''
module dut #(parameter type T = logic) (output logic o);
  T x = 1'b1;
  assign o = x;
endmodule
''')
c('VV','vv08_multiline_init','an initializer spanning lines',r'''
module dut #(parameter type T = logic [7:0], parameter int P = 3) (output logic [7:0] o);
  T x = (P +
         8'h10);
  assign o = x;
endmodule
''')
c('VV','vv09_override_struct','a child type parameter overridden by a package struct',r'''
package p;
  typedef struct packed { logic [3:0] a; } s_t;
endpackage
module child #(parameter type T = logic [3:0]) (output logic [3:0] o);
  T x = 4'h7;
  assign o = x;
endmodule
module dut (output logic [3:0] o);
  child #(.T(p::s_t)) u (.o(o));
endmodule
''')
c('VV','vv10_real_tp','a real type parameter with an initializer',r'''
module dut #(parameter type T = real) (output logic o);
  T x = 1.5;
  assign o = (x > 1.0);
endmodule
''')
c('VV','vv11_chain_localparam','a localparam type chained to a type parameter',r'''
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o);
  localparam type L = T;
  L x = 4'h2;
  assign o = x;
endmodule
''')
c('VV','vv12_enum_tp','an enum type parameter with an initializer',r'''
package p;
  typedef enum logic [1:0] { A, B, C } e_t;
endpackage
module dut #(parameter type T = p::e_t) (output logic [1:0] o);
  T x = p::B;
  assign o = x;
endmodule
''')
c('VV','vv13_noinit_ctl','control: no initializer',r'''
module dut #(parameter type T = logic [3:0]) (input logic [3:0] i, output logic [3:0] o);
  T x;
  assign x = i;
  assign o = x;
endmodule
''')
c('VV','vv14_crlf','a CRLF file',r'''
module dut #(parameter type T = logic [3:0]) (output logic [3:0] o);
  T x = 4'h5;
  assign o = x;
endmodule
''',crlf=True)
c('VV','vv15_two_inst','two instances with different overrides',r'''
module child #(parameter type T = logic [3:0]) (output logic [7:0] o);
  T x = '1;
  assign o = 8'(x);
endmodule
module dut (output logic [7:0] o, output logic [7:0] p);
  child #(.T(logic [1:0])) a (.o(o));
  child #(.T(logic [5:0])) b (.o(p));
endmodule
''')
# ---- VA: subroutine-local fixed arrays
c('VA','va01_desc_range','a descending ranged local array',r'''
package p;
  function automatic int f(int s);
    int v [3:0];
    v[0] = s;
    return v[0];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
''')
c('VA','va02_param_range','a parameter-expression ranged local array in a module function',r'''
module dut #(parameter int N = 4) (output int o);
  function automatic int f(int s);
    int v [0:N-1];
    v[1] = s;
    return v[1];
  endfunction
  assign o = f(3);
endmodule
''')
c('VA','va03_range_then_size','a range then a size dimension',r'''
package p;
  function automatic int f(int s);
    int v [0:1][4];
    v[0][0] = s;
    return v[0][0];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
''')
c('VA','va04_two_declarators','two declarators, ranged and sized',r'''
package p;
  function automatic int f(int s);
    int a [0:3], b [4];
    a[0] = s;
    b[0] = a[0];
    return b[0];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
''')
c('VA','va05_task_in_module','a module task with a ranged static local',r'''
module dut (input logic clk, output int o);
  task automatic t(output int r);
    logic [7:0] v [0:2];
    v[0] = 8'h3;
    r = v[0];
  endtask
  always_ff @(posedge clk) t(o);
endmodule
''')
c('VA','va06_iface_func','an interface function with a ranged local',r'''
interface ifc ();
  function automatic int f(int s);
    int v [0:3];
    v[2] = s;
    return v[2];
  endfunction
endinterface
module dut (output int o);
  ifc u ();
  assign o = u.f(5);
endmodule
''')
c('VA','va07_initializer','a ranged local with an initializer',r'''
package p;
  function automatic int f(int s);
    int v [0:3] = '{1, 2, 3, 4};
    return v[s];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(1);
endmodule
''')
c('VA','va08_macro_range','a range written by a macro',r'''
`define R [0:3]
package p;
  function automatic int f(int s);
    int v `R;
    v[0] = s;
    return v[0];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
''')
c('VA','va09_class_static','a static class method with a ranged local',r'''
package p;
  class c;
    static function int f(int s);
      byte v [1:4];
      v[1] = s;
      return v[1];
    endfunction
  endclass
endpackage
module dut (output int o);
  initial o = p::c::f(3);
endmodule
''')
c('VA','va10_spaces','a range written with spaces',r'''
package p;
  function automatic int f(int s);
    int v [ 0 : 3 ] ;
    v[0] = s;
    return v[0];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
''')
c('VA','va11_size_ctl','control: a size dimension',r'''
package p;
  function automatic int f(int s);
    int v [8];
    v[0] = s;
    return v[0];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
''')
c('VA','va12_crlf','a CRLF file',r'''
package p;
  function automatic int f(int s);
    int v [0:3];
    v[0] = s;
    return v[0];
  endfunction
endpackage
module dut (output int o);
  assign o = p::f(3);
endmodule
''',crlf=True)
# ---- VI: imported package declarations
c('VI','vi01_size_unpacked','a package variable with a size unpacked dimension',r'''
package p;
  logic [7:0] v [4];
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v[0];
endmodule
''')
c('VI','vi02_int_unpacked','an int package variable with an unpacked range',r'''
package p;
  int v [0:1];
endpackage
module dut (output int o);
  import p::*;
  assign o = v[1];
endmodule
''')
c('VI','vi03_bit_packed2d','a 2-D packed bit package variable',r'''
package p;
  bit [3:0][1:0] v;
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v;
endmodule
''')
c('VI','vi04_typedef_packed','a typedef with a packed dimension over it',r'''
package p;
  typedef logic [3:0] n_t;
  n_t [1:0] v;
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v;
endmodule
''')
c('VI','vi05_packed_and_unpacked','packed 2-D and unpacked',r'''
package p;
  logic [1:0][3:0] v [0:2];
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v[0];
endmodule
''')
c('VI','vi06_two_unpacked','two unpacked dimensions',r'''
package p;
  logic [7:0] v [0:1][0:3];
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v[1][2];
endmodule
''')
c('VI','vi07_explicit_import','an explicit import',r'''
package p;
  logic [1:0][7:0] v;
  logic [7:0] w [0:1];
endpackage
module dut (output logic [15:0] o, output logic [7:0] q);
  import p::v;
  import p::w;
  assign o = v;
  assign q = w[0];
endmodule
''')
c('VI','vi08_header_import','an interface importing in its header',r'''
package p;
  logic [1:0][7:0] v;
endpackage
interface ifc import p::*; ();
  logic [15:0] y;
  assign y = v;
endinterface
module dut (output logic [15:0] o);
  ifc u ();
  assign o = u.y;
endmodule
''')
c('VI','vi09_wire_packed2d','a package net with two packed dimensions',r'''
package p;
  wire [1:0][7:0] w;
endpackage
module dut (output logic [15:0] o);
  import p::*;
  assign o = w;
endmodule
''')
c('VI','vi10_multiline','a multi-line declaration',r'''
package p;
  logic [1:0]
        [7:0] v
        [0:1];
endpackage
module dut (output logic [15:0] o);
  import p::*;
  assign o = v[0];
endmodule
''')
c('VI','vi11_crlf','a CRLF file',r'''
package p;
  logic [1:0][7:0] v;
  logic [7:0] w [0:1];
endpackage
module dut (output logic [15:0] o, output logic [7:0] q);
  import p::*;
  assign o = v;
  assign q = w[1];
endmodule
''',crlf=True)
c('VI','vi12_signed','a signed 2-D packed variable',r'''
package p;
  logic signed [1:0][7:0] v;
endpackage
module dut (output logic [15:0] o);
  import p::*;
  assign o = v;
endmodule
''')
c('VI','vi13_reg','a reg 2-D packed variable',r'''
package p;
  reg [1:0][3:0] v;
endpackage
module dut (output logic [7:0] o);
  import p::*;
  assign o = v;
endmodule
''')
c('VI','vi14_scalar_unpacked','a scalar with an unpacked dimension',r'''
package p;
  logic v [0:1];
endpackage
module dut (output logic o);
  import p::*;
  assign o = v[0];
endmodule
''')
c('VI','vi15_queue','a queue and a dynamic array',r'''
package p;
  int q [$];
  int d [];
endpackage
module dut (output int o);
  import p::*;
  initial o = q.size() + d.size();
endmodule
''')
c('VI','vi16_macro_dim','a packed dimension written by a macro',r'''
`define W 8
package p;
  logic [1:0][`W-1:0] v;
endpackage
module dut (output logic [15:0] o);
  import p::*;
  assign o = v;
endmodule
''')
c('VI','vi17_two_pkgs_same_pos','two packages, same declarator position, two modules',r'''
package p;
  logic [1:0][7:0] v;
endpackage
package q;
  logic [1:0][7:0] v;
endpackage
module a (output logic [15:0] o);
  import p::*;
  assign o = v;
endmodule
module b (output logic [15:0] o);
  import q::*;
  assign o = v;
endmodule
module dut (output logic [15:0] o1, output logic [15:0] o2);
  a ua (.o(o1));
  b ub (.o(o2));
endmodule
''')
c('VI','vi18_three_packed','three packed dimensions',r'''
package p;
  logic [1:0][1:0][3:0] v;
endpackage
module dut (output logic [15:0] o);
  import p::*;
  assign o = v;
endmodule
''')
c('VI','vi19_struct_unpacked','a package struct variable with an unpacked dimension',r'''
package p;
  typedef struct packed { logic [3:0] a; } s_t;
  s_t v [0:1];
endpackage
module dut (output logic [3:0] o);
  import p::*;
  assign o = v[0].a;
endmodule
''')
# ---- VG: interface generate scope left sides
c('VG','vg01_case_gen','an interface case-generate scope',r'''
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT, parameter int K = 1) ();
  logic [31:0] i_gen;
  case (K)
    1: begin : c1
      assign i_gen = C.n;
    end
    default: begin : cd
      assign i_gen = 0;
    end
  endcase
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  assign o = u.i_gen;
endmodule
''')
c('VG','vg02_genlocal','a generate-local net in an interface',r'''
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] y;
  if (1) begin : gi
    logic [31:0] q;
    assign q = C.n;
    assign y = q;
  end
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  assign o = u.y;
endmodule
''')
c('VG','vg03_param_plain','a plain int parameter value in an interface generate scope',r'''
interface ifc #(parameter int P = 9) ();
  logic [31:0] i_gen;
  if (1) begin : gi
    assign i_gen = P;
  end
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  assign o = u.i_gen;
endmodule
''')
c('VG','vg04_iface_in_modgen','an interface instantiated in a module generate scope',r'''
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] i_gen;
  if (1) begin : gi
    assign i_gen = C.n;
  end
endinterface
module dut (output logic [31:0] o);
  if (1) begin : gm
    ifc u ();
    assign o = u.i_gen;
  end
endmodule
''')
c('VG','vg05_namesake_typed','a parent namesake with a struct type',r'''
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] i_gen;
  if (1) begin : gi
    assign i_gen = C.n;
  end
endinterface
module dut (output logic [31:0] o);
  p::cfg_t i_gen;
  assign i_gen = '{n: 1};
  ifc u ();
  assign o = u.i_gen + i_gen.n;
endmodule
''')
c('VG','vg06_for_gen','an interface for-generate assigning a scalar per iteration',r'''
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] a0, a1;
  for (genvar i = 0; i < 1; i++) begin : gf
    assign a0 = C.n;
  end
  assign a1 = C.n;
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  assign o = u.a0 + u.a1;
endmodule
''')
c('VG','vg07_iface_port','an interface port signal assigned in its generate scope',r'''
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) (output logic [31:0] y);
  if (1) begin : gi
    assign y = C.n;
  end
endinterface
module dut (output logic [31:0] o);
  ifc u (.y(o));
endmodule
''')
c('VG','vg08_two_ifaces','two interface instances with overrides',r'''
package p;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
  localparam cfg_t LIT2 = '{n: 7};
endpackage
interface ifc #(parameter p::cfg_t C = p::LIT) ();
  logic [31:0] i_gen;
  if (1) begin : gi
    assign i_gen = C.n;
  end
endinterface
module dut (output logic [31:0] o);
  ifc u ();
  ifc #(.C(p::LIT2)) w ();
  assign o = u.i_gen + w.i_gen;
endmodule
''')
# ---- VP: anonymous packed struct array type parameter
c('VP','vp01_two_dims','an anonymous packed struct with two dimensions',r'''
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0][2:0]) (input T i, output T o);
  assign o = i;
endmodule
''')
c('VP','vp02_bitsel_lhs','a bit-select left side',r'''
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input logic [1:0] i, output T o);
  assign o[0] = i;
  assign o[1] = i;
endmodule
''')
c('VP','vp03_override_parent','an override from the parent',r'''
module child #(parameter type T = logic [3:0]) (input T i, output T o);
  assign o = i;
endmodule
module dut (input logic [3:0] i, output logic [3:0] o);
  child #(.T(struct packed { logic a; logic b; } [1:0])) u (.i(i), .o(o));
endmodule
''')
c('VP','vp04_iface','an interface type parameter',r'''
interface ifc #(parameter type T = struct packed { logic a; logic b; } [1:0]) ();
  T x, y;
  assign y = x;
endinterface
module dut (input logic [3:0] i, output logic [3:0] o);
  ifc u ();
  assign u.x = i;
  assign o = u.y;
endmodule
''')
c('VP','vp05_always_ctl','control: an always_comb assignment only',r'''
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input T i, output T o);
  always_comb o = i;
endmodule
''')
c('VP','vp06_two_tps','two type parameters, one assigned',r'''
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0],
             parameter type U = struct packed { logic c; } [2:0]) (input T i, input U j, output T o, output U p);
  assign o = i;
  always_comb p = j;
endmodule
''')
c('VP','vp07_union','an anonymous packed union with dimensions in a body net',r'''
module dut #(parameter type T = union packed { logic [1:0] a; logic [1:0] b; } [1:0]) (input logic [3:0] i, output logic [3:0] o);
  T w;
  assign w = i;
  assign o = w;
endmodule
''')
c('VP','vp08_member_lhs','a member-select left side',r'''
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input logic i, output T o);
  assign o[0].a = i;
  assign o[0].b = i;
  assign o[1] = '0;
endmodule
''')
c('VP','vp09_named_struct_ctl','control: a named struct element',r'''
package p;
  typedef struct packed { logic a; logic b; } s_t;
endpackage
module dut #(parameter type T = p::s_t [1:0]) (input T i, output T o);
  assign o = i;
endmodule
''')
c('VP','vp10_nda','a net declaration assignment',r'''
module dut #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input logic [3:0] i, output logic [3:0] o);
  wire T w = i;
  assign o = w;
endmodule
''')
# ---- VN: definition net of a named-element array type parameter
c('VN','vn01_three_inst','three instances with three overrides',r'''
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o1, o2, o3);
  child #(.id_t(logic [1:0])) u1 (.a(a), .o(o1));
  child #(.id_t(logic [2:0])) u2 (.a(a), .o(o2));
  child #(.id_t(logic [3:0])) u3 (.a(a), .o(o3));
endmodule
''')
c('VN','vn02_dfs_vs_bfs','the last instance by depth-first or breadth-first order',r'''
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module mid (input logic [15:0] a, output logic [15:0] o);
  child #(.id_t(logic [2:0])) c (.a(a), .o(o));
endmodule
module dut (input logic [15:0] a, output logic [15:0] o1, o2);
  mid m (.a(a), .o(o1));
  child #(.id_t(logic [1:0])) c1 (.a(a), .o(o2));
endmodule
''')
c('VN','vn03_pkg_elem','a package typedef element override',r'''
package p;
  typedef logic [2:0] b_t;
endpackage
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o);
  child #(.id_t(p::b_t)) u (.a(a), .o(o));
endmodule
''')
c('VN','vn04_port_and_body','a port and a body net of the type',r'''
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input rt_t a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = 16'(x);
endmodule
module dut (input logic [7:0] a, output logic [15:0] o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
''')
c('VN','vn05_gen_for','instances in a for-generate with genvar-dependent overrides',r'''
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    child #(.id_t(logic [i+1:0])) u (.a(a), .o(o[i]));
  end
endmodule
''')
c('VN','vn06_two_defs','two definitions interleaved',r'''
module ca #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module cb #(parameter type id_t = logic, localparam type rt_t = id_t [1:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o1, o2, o3);
  ca #(.id_t(logic [1:0])) u1 (.a(a), .o(o1));
  cb #(.id_t(logic [2:0])) u2 (.a(a), .o(o2));
  ca #(.id_t(logic [2:0])) u3 (.a(a), .o(o3));
endmodule
''')
c('VN','vn07_iface','an interface with a named-element array type parameter',r'''
interface ifc #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) ();
  rt_t x;
endinterface
module dut (input logic [15:0] a, output logic [15:0] o);
  ifc #(.id_t(logic [1:0])) u ();
  assign u.x = a;
  assign o = u.x;
endmodule
''')
c('VN','vn08_struct_elem','a struct element override',r'''
package p;
  typedef struct packed { logic [1:0] a; } s_t;
endpackage
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o);
  child #(.id_t(p::s_t)) u (.a(a), .o(o));
endmodule
''')
c('VN','vn09_param_not_local','a non-local parameter type over the element',r'''
module child #(parameter type id_t = logic, parameter type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  assign x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
''')
c('VN','vn10_variable_body','a variable (not net) declared with the type, always_comb driven',r'''
module child #(parameter type id_t = logic, localparam type rt_t = id_t [3:0]) (input logic [15:0] a, output logic [15:0] o);
  rt_t x;
  always_comb x = a;
  assign o = x;
endmodule
module dut (input logic [15:0] a, output logic [15:0] o);
  child #(.id_t(logic [1:0])) u (.a(a), .o(o));
endmodule
''')
c('VK','vn11_param_depth_two_inst','a parameter-dependent dimension in two instances',r'''
module child #(parameter type id_t = logic, localparam int D = (1 << $bits(id_t)), localparam type rt_t = id_t [D-1:0]) (input logic [15:0] r, output logic o);
  rt_t y;
  assign y = r;
  assign o = ^y;
endmodule
module dut (input logic [15:0] r, output logic o1, o2);
  child #(.id_t(logic [1:0])) u (.r(r), .o(o1));
  child #(.id_t(logic)) w (.r(r), .o(o2));
endmodule
''')
c('VK','vn12_param_bound_override','a dimension bound by an overridden value parameter',r'''
module child #(parameter type id_t = logic, parameter int N = 4, localparam type rt_t = id_t [N-1:0]) (input logic [15:0] r, output logic o);
  rt_t y;
  assign y = r;
  assign o = ^y;
endmodule
module dut (input logic [15:0] r, output logic o1, o2);
  child #(.id_t(logic [1:0]), .N(3)) u (.r(r), .o(o1));
  child #(.id_t(logic [2:0]), .N(2)) w (.r(r), .o(o2));
endmodule
''')
c('VK','vn13_param_depth_gen','a parameter-dependent dimension, instance in a generate block',r'''
module child #(parameter type id_t = logic, parameter int N = 4, localparam type rt_t = id_t [N-1:0]) (input logic [15:0] r, output logic o);
  rt_t y;
  assign y = r;
  assign o = ^y;
endmodule
module dut (input logic [15:0] r, output logic o);
  if (1) begin : g
    child #(.id_t(logic [1:0]), .N(3)) u (.r(r), .o(o));
  end
endmodule
''')
c('VP','vp11_cond_assign_two_inst','an assignment in one instance only through a generate condition',r'''
module child #(parameter type T = struct packed { logic a; logic b; } [1:0], parameter bit K = 1) (input T i, output T o);
  if (K) begin : ga
    assign o = i;
  end else begin : gb
    always_comb o = i;
  end
endmodule
module dut (input logic [3:0] i, output logic [3:0] o1, o2);
  child #(.K(1)) u (.i(i), .o(o1));
  child #(.K(0)) w (.i(i), .o(o2));
endmodule
''')
c('VP','vp12_two_inst_noassign_second','two definitions sharing nothing, one assigning',r'''
module ca #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input T i, output T o);
  assign o = i;
endmodule
module cb #(parameter type T = struct packed { logic a; logic b; } [1:0]) (input T i, output T o);
  always_comb o = i;
endmodule
module dut (input logic [3:0] i, output logic [3:0] o1, o2);
  ca u (.i(i), .o(o1));
  cb w (.i(i), .o(o2));
endmodule
''')
c('VK','vn14_first_overrides_array','a parameter-bound dimension, the first instance overriding the array itself',r'''
module child #(parameter type id_t = logic, parameter int N = 4, parameter type rt_t = id_t [N-1:0]) (input logic [15:0] r, output logic o);
  rt_t y;
  assign y = r;
  assign o = ^y;
endmodule
module dut (input logic [15:0] r, output logic o1, o2, o3);
  child #(.rt_t(logic [5:0])) u (.r(r), .o(o1));
  child #(.id_t(logic [1:0]), .N(3)) w (.r(r), .o(o2));
  child #(.id_t(logic [2:0]), .N(2)) x (.r(r), .o(o3));
endmodule
''')
c('VK','vn15_nested_first','a parameter-bound dimension, the first instance nested one level down',r'''
module child #(parameter type id_t = logic, parameter int N = 4, localparam type rt_t = id_t [N-1:0]) (input logic [15:0] r, output logic o);
  rt_t y;
  assign y = r;
  assign o = ^y;
endmodule
module mid (input logic [15:0] r, output logic o);
  child #(.id_t(logic [2:0]), .N(2)) c (.r(r), .o(o));
endmodule
module dut (input logic [15:0] r, output logic o1, o2);
  mid m (.r(r), .o(o1));
  child #(.id_t(logic [1:0]), .N(3)) w (.r(r), .o(o2));
endmodule
''')
