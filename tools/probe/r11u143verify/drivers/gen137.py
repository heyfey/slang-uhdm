#!/usr/bin/env python3
"""gen137.py: writes the fresh cases of pass 137's sixteen laws (twelve + r11u139's four roads) and the two v11u137
refinements under cases/. Cases under p137_elabclone/ are judged in --elabuhdm mode (both producers)."""
import os
B=os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','cases')
C={}
L='elabCloneFullNameUnstored137'
C['p137_elabclone/ee01_iface_process']=f'''// § {L}
// case ee01: an interface with its own always block and function, instantiated in top
interface bus_if(input logic clk);
  logic [3:0] d, q;
  function automatic logic [3:0] nx(input logic [3:0] v); return v + 1; endfunction
  always_ff @(posedge clk) q <= nx(d);
endinterface
module top(input logic clk, input logic [3:0] d, output logic [3:0] q);
  bus_if b(.clk(clk));
  assign b.d = d;
  assign q = b.q;
endmodule
'''
C['p137_elabclone/ee02_func_struct_local']=f'''// § {L}
// case ee02: a sub-module function with a struct-typed local of a module typedef
module sub(input logic [7:0] a, output logic [7:0] y);
  typedef struct packed {{ logic [3:0] hi; logic [3:0] lo; }} pr_t;
  function automatic logic [7:0] swap(input logic [7:0] v);
    pr_t t;
    t = v;
    return {{t.lo, t.hi}};
  endfunction
  assign y = swap(a);
endmodule
module top(input logic [7:0] a, output logic [7:0] y); sub u(.a(a), .y(y)); endmodule
'''
C['p137_elabclone/ee03_latch_case_block']=f'''// § {L}
// case ee03: always_latch with a case whose item holds a named block, in a sub-module
module sub(input logic en, input logic [1:0] s, input logic [3:0] d, output logic [3:0] q);
  always_latch begin
    if (en) begin
      case (s)
        2'd0: begin : c0 q = d; end
        default: begin : cd q = ~d; end
      endcase
    end
  end
endmodule
module top(input logic en, input logic [1:0] s, input logic [3:0] d, output logic [3:0] q);
  sub u(.en(en), .s(s), .d(d), .q(q));
endmodule
'''
C['p137_elabclone/ee04_task_output_arg']=f'''// § {L}
// case ee04: a sub-module task with an output argument called from an initial block
module sub(output int r);
  task automatic dbl(input int a, output int b); b = a * 2; endtask
  initial begin
    int t;
    dbl(3, t);
    r = t;
  end
endmodule
module top(output int r); sub u(.r(r)); endmodule
'''
L='packedArrTdElemRefName137'
C['p137_patd/pd01_union_elem']=f'''// § {L}
// case pd01: a packed-array typedef over a packed union typedef
module top(output logic [7:0] o);
  typedef union packed {{ logic [3:0] a; logic [3:0] b; }} u_t;
  typedef u_t [1:0] ua_t;
  ua_t v;
  assign v = 8'h5A;
  assign o = v;
endmodule
'''
C['p137_patd/pd02_port_type']=f'''// § {L}
// case pd02: a packed-array typedef of an enum used as a sub-module port type
package ep;
  typedef enum logic [1:0] {{R = 0, G = 1, Bl = 2}} c_t;
  typedef c_t [2:0] ca_t;
endpackage
module sub(input ep::ca_t x, output logic [5:0] o); assign o = x; endmodule
module top(input logic [5:0] i, output logic [5:0] o);
  ep::ca_t w;
  assign w = ep::ca_t'(i);
  sub u(.x(w), .o(o));
endmodule
'''
C['p137_patd/pd03_vec_elem']=f'''// § {L}
// case pd03: a packed-array typedef over a plain logic-vector typedef
module top(output logic [7:0] o);
  typedef logic [3:0] n_t;
  typedef n_t [1:0] nn_t;
  nn_t v;
  assign v = 8'hC3;
  assign o = v;
endmodule
'''
C['p137_patd/pd04_genblock_td']=f'''// § {L}
// case pd04: a packed-array typedef over an enum declared inside a generate block
module top(output logic [3:0] o);
  if (1) begin : g
    typedef enum logic [1:0] {{X0, X1, X2}} k_t;
    typedef k_t [1:0] ka_t;
    ka_t v;
    assign v = {{X1, X2}};
    assign o = v;
  end
endmodule
'''
L='emptyNamedConnLowConnAtDecl137'
C['p137_emptyconn/en01_inout']=f'''// § {L}
// case en01: an explicitly empty named connection of an inout port
module sub(input logic a, inout wire b, output logic c);
  assign c = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(), .c(y));
endmodule
'''
C['p137_emptyconn/en02_struct_port']=f'''// § {L}
// case en02: an explicitly empty named connection of a packed-struct output port
package sp; typedef struct packed {{ logic v; logic [2:0] d; }} s_t; endpackage
module sub(input logic a, output sp::s_t s, output logic c);
  assign s = {{a, 3'b101}};
  assign c = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .s(), .c(y));
endmodule
'''
C['p137_emptyconn/en03_multiline_attr_decl']=f'''// § {L}
// case en03: the empty port's declaration carries an attribute and spans two lines
module sub(input logic a,
           (* keep *) output logic
             [3:0] b,
           output logic c);
  assign b = {{4{{a}}}};
  assign c = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(), .c(y));
endmodule
'''
C['p137_emptyconn/en04_with_wildcard']=f'''// § {L}
// case en04: an explicitly empty named connection next to a wildcard connection
module sub(input logic a, output logic b, output logic c);
  assign b = a; assign c = ~a;
endmodule
module top(input logic a, output logic c);
  sub u(.*, .b());
endmodule
'''
L='unsignedScalarVecTsAtKeyword137'
C['p137_unsigned/us01_unpacked_mem']=f'''// § {L}
// case us01: scalar bit unsigned and logic unsigned with unpacked dimensions
module top(input logic i, output logic o);
  bit unsigned mem [4];
  logic unsigned q [0:1];
  assign q[0] = i;
  assign o = q[0];
endmodule
'''
C['p137_unsigned/us02_typedef']=f'''// § {L}
// case us02: a typedef of a scalar bit unsigned, used by a net and a variable
module top(input logic i, output logic o);
  typedef bit unsigned b_t;
  typedef logic unsigned l_t;
  b_t v;
  l_t w;
  assign w = i;
  assign o = w;
endmodule
'''
C['p137_unsigned/us03_genblock_iface']=f'''// § {L}
// case us03: scalar reg unsigned in a generate block and logic unsigned in an interface with a modport
interface sif;
  logic unsigned s;
  modport m(input s);
endinterface
module top(input logic i, output logic o);
  sif bi();
  assign bi.s = i;
  for (genvar g = 0; g < 1; g++) begin : gg
    reg unsigned r;
    assign o = bi.s;
  end
endmodule
'''
L='unsignedScalarVecTsAtKeyword137'
C['p137_defwire/dw01_tri_genblock']=f'''// § {L} (refinement R11V137_DEFWIRE_OFF)
// case dw01: tri logic unsigned body nets inside a generate block, one with an initializer
module top(input logic i, output logic o);
  if (1) begin : g
    tri logic unsigned t;
    wire logic unsigned w = i;
    assign t = w;
    assign o = t;
  end
endmodule
'''
C['p137_defwire/dw02_wor_uwire']=f'''// § {L} (refinement R11V137_DEFWIRE_OFF)
// case dw02: wor and uwire logic unsigned body nets in a sub-module
module sub(input logic a, output logic b);
  wor logic unsigned x;
  uwire logic unsigned u;
  assign x = a;
  assign u = x;
  assign b = u;
endmodule
module top(input logic a, output logic b); sub s(.a(a), .b(b)); endmodule
'''
C['p137_defwire/dw03_wire_unpacked']=f'''// § {L} (refinement R11V137_DEFWIRE_OFF)
// case dw03: a wire logic unsigned body net with an unpacked dimension
module top(input logic i, output logic o);
  wire logic unsigned m [2];
  assign m[0] = i;
  assign m[1] = ~i;
  assign o = m[1];
endmodule
'''
L='constCallNameSpan137'
C['p137_callspan/cs01_unpacked_dim']=f'''// § {L}
// case cs01: a user call in an unpacked dimension bound
module top(output logic o);
  function automatic int sz(input int x); return x * 2; endfunction
  logic m [sz(2)];
  logic n [0:sz(1)-1];
  assign m[0] = 1'b1;
  assign o = m[0];
endmodule
'''
C['p137_callspan/cs02_param_port_range']=f'''// § {L}
// case cs02: a package call in a parameter's range and in a port range
package fp; function automatic int w(input int x); return x + 1; endfunction endpackage
module top #(parameter logic [fp::w(3)-1:0] P = 0) (output logic [fp::w(2)-1:0] o);
  assign o = P[2:0];
endmodule
'''
C['p137_callspan/cs03_genif_op_of_calls']=f'''// § {L}
// case cs03: a generate-if condition adding two calls
module top(output logic [3:0] o);
  function automatic int f(input int x); return x; endfunction
  if ((f(1) + f(2)) > 2) begin : g
    assign o = 4'd5;
  end else begin : h
    assign o = 4'd6;
  end
endmodule
'''
C['p137_callspan/cs04_genblock_lp_range']=f'''// § {L}
// case cs04: a call in the range of a net declared in a generate block
module top(output logic [3:0] o);
  function automatic int f(input int x); return x + 3; endfunction
  if (1) begin : g
    logic [f(1)-1:0] w;
    assign w = 4'hA;
    assign o = w;
  end
endmodule
'''
L='connReplTsRefThroughPort137'
C['p137_repl/rp01_net_operand_ctl']=f'''// § {L}
// case rp01: control, a replication of a NET (not folded) as the actual
module sub(input logic [3:0] m, output logic [3:0] o); assign o = m; endmodule
module top(input logic a, output logic [3:0] o);
  sub u(.m({{4{{a}}}}), .o(o));
endmodule
'''
C['p137_repl/rp02_struct_port']=f'''// § {L}
// case rp02: a constant replication connected to a packed-struct port, count from a localparam
package rp; typedef struct packed {{ logic [3:0] a; logic [3:0] b; }} s_t; endpackage
module sub(input rp::s_t s, output logic [7:0] o); assign o = s; endmodule
module top(output logic [7:0] o);
  localparam int N = 2;
  sub u(.s({{N{{4'hC}}}}), .o(o));
endmodule
'''
C['p137_repl/rp03_genfor']=f'''// § {L}
// case rp03: a constant replication actual on an instance inside a generate for
module sub(input logic [5:0] m, output logic [5:0] o); assign o = m; endmodule
module top(output logic [11:0] o);
  for (genvar g = 0; g < 2; g++) begin : gl
    sub u(.m({{3{{2'b10}}}}), .o(o[g*6 +: 6]));
  end
endmodule
'''
C['p137_repl/rp04_nonansi_child']=f'''// § {L}
// case rp04: a constant replication actual to a non-ANSI child port
module sub(m, o);
  input [7:0] m;
  output [7:0] o;
  assign o = m;
endmodule
module top(output logic [7:0] o);
  sub u(.m({{2{{4'hA}}}}), .o(o));
endmodule
'''
L='pureVirtProtoSpan137'
C['p137_purevirt/pv01_module_class_defaults']=f'''// § {L}
// case pv01: a pure virtual function with default and multi-line arguments in a class inside a module
module top();
  virtual class Base;
    pure virtual function void f(input int a = 1,
                                 output int b);
  endclass
endmodule
'''
C['p137_purevirt/pv02_iface_class_task']=f'''// § {L}
// case pv02: a pure virtual task with ref arguments in an interface class
package ip;
  interface class Ifc;
    pure virtual task t(ref int a, input int b);
  endclass
endpackage
module top(); endmodule
'''
C['p137_purevirt/pv03_local_task']=f'''// § {L} (refinement R11V137_PVQUAL_OFF)
// case pv03: pure virtual local task and pure virtual protected function returning a package typedef
package tq; typedef logic [3:0] n_t; endpackage
virtual class K;
  pure virtual local task lt(int a);
  pure virtual protected function tq::n_t pf();
endclass
module top(); endmodule
'''
C['p137_purevirt/pv04_extends_override']=f'''// § {L} (refinement R11V137_PVQUAL_OFF)
// case pv04: an abstract class with a pure virtual protected task, extended by an abstract class adding its own
virtual class A;
  pure virtual protected task run();
endclass
virtual class Bc extends A;
  pure virtual function bit ok(int x);
endclass
module top(); endmodule
'''
L='taggedUnionElabSpan137'
C['p137_tagged/tu01_struct_member']=f'''// § {L}
// case tu01: a tagged packed union with a struct member
module top(output logic [7:0] o);
  union tagged packed {{
    struct packed {{ logic [3:0] a; logic [3:0] b; }} s;
    logic [7:0] w;
  }} un;
  initial un = tagged w (8'h3C);
  assign o = un.w;
endmodule
'''
C['p137_tagged/tu02_genblock']=f'''// § {L}
// case tu02: a tagged packed union declared in a generate block
module top();
  if (1) begin : g
    union tagged packed {{
      bit [3:0] p;
      bit [3:0] q;
    }} u2;
    initial u2 = tagged p (4'd2);
  end
endmodule
'''
C['p137_tagged/tu03_signed']=f'''// § {L}
// case tu03: a tagged packed signed union
module top();
  union tagged packed signed {{
    bit [5:0] a;
    bit [5:0] b;
  }} su;
  initial su = tagged a (6'd9);
endmodule
'''
L='defNetTypeParamDefault137'
C['p137_defnettp/tp01_pkg_typedef_default']=f'''// § {L}
// case tp01: a type parameter defaulting to a package struct typedef, one net
package tpp; typedef struct packed {{ logic [2:0] a; logic b; }} s_t; endpackage
module sub #(parameter type T = tpp::s_t) (output logic [3:0] o);
  T d;
  assign d = 4'hB;
  assign o = d;
endmodule
module top(output logic [3:0] o); sub u(.o(o)); endmodule
'''
C['p137_defnettp/tp02_signed_vec_default']=f'''// § {L}
// case tp02: a type parameter defaulting to a signed bit vector, overridden with logic [3:0]
module sub #(parameter type T = bit signed [3:0]) ();
  T x;
endmodule
module top(); sub #(.T(logic [3:0])) u(); sub v(); endmodule
'''
C['p137_defnettp/tp03_unit_enum_default']=f'''// § {L}
// case tp03: a type parameter defaulting to a $unit enum typedef
typedef enum logic [1:0] {{E0, E1, E2}} ue_t;
module sub #(parameter type T = ue_t) (output logic [1:0] o);
  T s;
  assign s = E1;
  assign o = s;
endmodule
module top(output logic [1:0] o); sub u(.o(o)); endmodule
'''
C['p137_defnettp/tp04_dependent_default']=f'''// § {L}
// case tp04: a type parameter whose default depends on a value parameter
module sub #(parameter int W = 5, parameter type T = logic [W-1:0]) (output logic [4:0] o);
  T v;
  assign v = '1;
  assign o = v;
endmodule
module top(output logic [4:0] o); sub u(.o(o)); endmodule
'''
L='aliasCloneTakesTargetFile137'
C['p137_aliasfile/al01_enum_unpacked']=f'''// § {L}
// case al01: an unpacked-array alias of an enum typedef in a package
package ap;
  typedef enum logic [1:0] {{Q0, Q1}} e_t;
  typedef e_t ea[3];
endpackage
module top();
  ap::ea v;
endmodule
'''
C['p137_aliasfile/al02_union_module']=f'''// § {L}
// case al02: an unpacked-array alias of a packed union typedef in a module
module top();
  typedef union packed {{ logic [1:0] x; logic [1:0] y; }} u_t;
  typedef u_t ua[4];
  ua v;
endmodule
'''
C['p137_aliasfile/al03_chain']=f'''// § {L}
// case al03: an alias chain over a package struct typedef
package cp2;
  typedef struct packed {{ logic k; }} a;
  typedef a b[2];
  typedef b c[3];
endpackage
module top();
  cp2::c v;
endmodule
'''
L='defNetScopedPkgArrTdShares137'
C['p137_scopedarrtd/sd01_enum_elem']=f'''// § {L}
// case sd01: a package-scoped unpacked-array typedef of an enum element
package sp2;
  typedef enum logic [1:0] {{S0, S1, S2}} e_t;
  typedef e_t ea[4];
endpackage
module dut(output logic [1:0] o);
  sp2::ea c;
  assign c[2] = sp2::S1;
  assign o = c[2];
endmodule
'''
C['p137_scopedarrtd/sd02_port_type']=f'''// § {L}
// case sd02: a package-scoped unpacked-array typedef as a sub-module port type
package sp3;
  typedef logic [3:0] b[2];
endpackage
module sub(input sp3::b x, output logic [3:0] o); assign o = x[1]; endmodule
module dut(output logic [3:0] o);
  sp3::b c;
  assign c[0] = 4'h1;
  assign c[1] = 4'h2;
  sub u(.x(c), .o(o));
endmodule
'''
C['p137_scopedarrtd/sd03_ascending_init']=f'''// § {L}
// case sd03: an ascending-range package array typedef, a variable with a pattern initializer
package sp4;
  typedef struct packed {{ logic a; logic b; }} s_t;
  typedef s_t sa[0:2];
endpackage
module dut(output logic o);
  sp4::sa c = '{{default: '0}};
  assign o = c[1].b;
endmodule
'''
L='structParamPathBaseAtMember137'
PK4='package p;\n  typedef struct packed { int DAT; int ADR; } cfg_t;\nendpackage\n'
C['p137_pathbase/sp01_unpacked_dim']=f'''// § {L}
// case sp01: a struct-parameter member path in an unpacked dimension
{PK4}module top #(parameter p::cfg_t CFG = '{{DAT: 4, ADR: 2}}) (output logic o);
  logic m [CFG.DAT];
  assign m[0] = 1'b1;
  assign o = m[0];
endmodule
'''
C['p137_pathbase/sp02_typedef_range']=f'''// § {L}
// case sp02: a struct-parameter member path in a module typedef's range
{PK4}module top #(parameter p::cfg_t CFG = '{{DAT: 6, ADR: 2}}) (output logic [5:0] o);
  typedef logic [CFG.DAT-1:0] d_t;
  d_t v;
  assign v = '1;
  assign o = v;
endmodule
'''
C['p137_pathbase/sp03_genif_and']=f'''// § {L}
// case sp03: two member paths joined by && in a generate-if condition
{PK4}module top #(parameter p::cfg_t CFG = '{{DAT: 8, ADR: 3}}) (output logic [3:0] o);
  if (CFG.DAT > 4 && CFG.ADR < 8) begin : g
    assign o = 4'd1;
  end else begin : h
    assign o = 4'd2;
  end
endmodule
'''
C['p137_pathbase/sp04_genblock_net_range']=f'''// § {L}
// case sp04: a member path in the range of a net declared inside a generate block
{PK4}module top #(parameter p::cfg_t CFG = '{{DAT: 4, ADR: 2}}) (output logic [3:0] o);
  if (1) begin : g
    logic [CFG.DAT-1:0] w;
    assign w = 4'h9;
    assign o = w;
  end
endmodule
'''
# net binding
L='caLhsDefNetUnlessOpRhs139'
C['p139_ca/ca01_nonansi_op']=f'''// § {L}
// case ca01: an operation right-hand side onto a non-ANSI output port
module top(a, b, y);
  input a, b;
  output y;
  wire y;
  assign y = a & b;
endmodule
'''
C['p139_ca/ca02_repl_rhs']=f'''// § {L}
// case ca02: a replication of a port as the right-hand side
module top(input logic a, output logic [1:0] y);
  assign y = {{2{{a}}}};
endmodule
'''
C['p139_ca/ca03_delay_op']=f'''// § {L}
// case ca03: a delayed operation right-hand side
module top(input logic a, input logic b, output logic y);
  assign #1 y = a | b;
endmodule
'''
C['p139_ca/ca04_inst_array_child']=f'''// § {L}
// case ca04: an assignment with a reference right-hand side inside the child of an array of instances
module sub(input logic a, output logic y); assign y = a; endmodule
module top(input logic [1:0] a, output logic [1:0] y);
  sub u[1:0](.a(a), .y(y));
endmodule
'''
L='ndaLeftmostLeafElab139'
C['p139_nda/nd01_concat_leftmost']=f'''// § {L}
// case nd01: a net declaration assignment whose left operand is a concatenation
module top(input logic [1:0] a, input logic [1:0] b, input logic [3:0] c, output logic [3:0] y);
  wire [3:0] w = {{a, b}} + c;
  assign y = w;
endmodule
'''
C['p139_nda/nd02_call_leftmost']=f'''// § {L}
// case nd02: a net declaration assignment whose left operand is a function call
module top(input logic [3:0] a, input logic [3:0] b, output logic [3:0] y);
  function automatic logic [3:0] inv(input logic [3:0] v); return ~v; endfunction
  wire [3:0] w = inv(a) & b;
  assign y = w;
endmodule
'''
C['p139_nda/nd03_cast_leftmost']=f'''// § {L}
// case nd03: a net declaration assignment whose left operand is a size cast
module top(input logic [1:0] a, input logic [3:0] b, output logic [3:0] y);
  wire [3:0] w = 4'(a) + b;
  assign y = w;
endmodule
'''
C['p139_nda/nd04_member_leftmost']=f'''// § {L}
// case nd04: a net declaration assignment whose left operand is a struct member of a port
package np2; typedef struct packed {{ logic f; logic g; }} s_t; endpackage
module top(input np2::s_t s, input logic b, output logic y);
  wire w = s.f ^ b;
  assign y = w;
endmodule
'''
L='clockingEventDefNet139'
C['p139_clk/ck01_edge']=f'''// § {L}
// case ck01: a default clocking block on an edge event
module top(input logic clk, input logic a, output logic y);
  default clocking cb @(edge clk); endclocking
  always @(posedge clk) y <= a;
endmodule
'''
C['p139_clk/ck02_bitsel_clock']=f'''// § {L}
// case ck02: a clocking block whose event is a bit-select of a port vector
module top(input logic [1:0] clks, input logic a, output logic y);
  clocking cb @(posedge clks[0]); input a; endclocking
  always @(posedge clks[0]) y <= a;
endmodule
'''
C['p139_clk/ck03_genblock_sub']=f'''// § {L}
// case ck03: a default clocking inside a sub-module instantiated in a generate block
module sub(input logic clk, input logic a, output logic y);
  default clocking @(negedge clk); endclocking
  always @(negedge clk) y <= a;
endmodule
module top(input logic clk, input logic a, output logic y);
  if (1) begin : g
    sub u(.clk(clk), .a(a), .y(y));
  end
endmodule
'''
L='connLeftmostLeafElab139'
C['p139_port/pc01_inst_array_op']=f'''// § {L}
// case pc01: an operation actual on an array of instances
module sub(input logic a, output logic y); assign y = ~a; endmodule
module top(input logic [1:0] p, input logic [1:0] q, output logic [1:0] y);
  sub u[1:0](.a(p & q), .y(y));
endmodule
'''
C['p139_port/pc02_paren_nested']=f'''// § {L}
// case pc02: a parenthesized nested operation actual
module sub(input logic a, output logic y); assign y = a; endmodule
module top(input logic p, input logic q, input logic r, output logic y);
  sub u(.a((p | q) & r), .y(y));
endmodule
'''
C['p139_port/pc03_param_sub_concat']=f'''// § {L}
// case pc03: a concatenation actual on a parameterized sub-module with an override
module sub #(parameter int W = 1) (input logic [W-1:0] a, output logic [W-1:0] y); assign y = a; endmodule
module top(input logic p, input logic q, output logic [1:0] y);
  sub #(.W(2)) u(.a({{p, q}}), .y(y));
endmodule
'''
C['p139_port/pc04_bitsel_right']=f'''// § {L}
// case pc04: an operation actual whose right operand is a bit-select
module sub(input logic a, output logic y); assign y = a; endmodule
module top(input logic p, input logic [1:0] q, output logic y);
  sub u(.a(p + q[1]), .y(y));
endmodule
'''
for k,v in C.items():
    d=os.path.join(B,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write(v)
print(len(C),'cases')
