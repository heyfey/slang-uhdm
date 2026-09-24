#!/usr/bin/env python3
"""gen_more.py: second batch of fresh cases, for the laws the first batch left without a judge-equal firing cell."""
import os
B=os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','cases')
C={}
L='caLhsDefNetUnlessOpRhs139'
C['p139_ca/ca05_partsel_rhs']=f'''// § {L}
// case ca05: a part-select right-hand side
module top(input logic [3:0] a, output logic [1:0] y);
  assign y = a[3:2];
endmodule
'''
C['p139_ca/ca06_member_rhs']=f'''// § {L}
// case ca06: a struct-member right-hand side
package cp6; typedef struct packed {{ logic f; logic g; }} s_t; endpackage
module top(input cp6::s_t s, output logic y);
  assign y = s.g;
endmodule
'''
C['p139_ca/ca07_ips_rhs_sub_two']=f'''// § {L}
// case ca07: an indexed part-select right-hand side in a sub-module instantiated twice
module sub(input logic [7:0] a, output logic [3:0] y);
  assign y = a[4 +: 4];
endmodule
module top(input logic [7:0] a, output logic [3:0] y1, output logic [3:0] y2);
  sub u1(.a(a), .y(y1));
  sub u2(.a(~a), .y(y2));
endmodule
'''
C['p139_ca/ca08_var_index_rhs']=f'''// § {L}
// case ca08: a variable-indexed element right-hand side
module top(input logic [1:0] i, input logic [3:0] a, output logic y);
  assign y = a[i];
endmodule
'''
L='ndaLeftmostLeafElab139'
C['p139_nda/nd05_compare']=f'''// § {L}
// case nd05: a net declaration assignment with an equality operation
module top(input logic [3:0] a, input logic [3:0] b, output logic y);
  wire w = a == b;
  assign y = w;
endmodule
'''
C['p139_nda/nd06_nested_left_chain']=f'''// § {L}
// case nd06: a nested binary left chain, three leaves
module top(input logic [3:0] a, input logic [3:0] b, input logic [3:0] c, output logic [7:0] y);
  wire [7:0] w = a * b + c;
  assign y = w;
endmodule
'''
C['p139_nda/nd07_logical_unary_left']=f'''// § {L}
// case nd07: a logical or whose left operand is a logical not
module top(input logic a, input logic b, output logic y);
  wire w = !a || b;
  assign y = w;
endmodule
'''
C['p139_nda/nd08_sub_two_inst']=f'''// § {L}
// case nd08: a net declaration assignment in a sub-module instantiated twice
module sub(input logic a, input logic b, output logic y);
  wire w = a ^ b;
  assign y = w;
endmodule
module top(input logic a, input logic b, output logic y1, output logic y2);
  sub u1(.a(a), .b(b), .y(y1));
  sub u2(.a(b), .b(a), .y(y2));
endmodule
'''
L='clockingEventDefNet139'
C['p139_clk/ck04_skews']=f'''// § {L}
// case ck04: a named clocking block with default skews and an output
module top(input logic clk, input logic a, output logic y);
  clocking cb @(posedge clk);
    default input #1step output #2;
    input a;
    output y;
  endclocking
endmodule
'''
C['p139_clk/ck05_two_blocks']=f'''// § {L}
// case ck05: a default clocking and a named clocking on different clocks
module top(input logic c1, input logic c2, input logic a, output logic y);
  default clocking d1 @(posedge c1); endclocking
  clocking n2 @(negedge c2); input a; endclocking
  always @(posedge c1) y <= a;
endmodule
'''
C['p139_clk/ck06_global_sub']=f'''// § {L}
// case ck06: a global clocking inside a sub-module
module sub(input logic clk, input logic a, output logic y);
  global clocking gc @(posedge clk); endclocking
  always @(posedge clk) y <= a;
endmodule
module top(input logic clk, input logic a, output logic y); sub u(.clk(clk), .a(a), .y(y)); endmodule
'''
L='packedArrTdElemRefName137'
C['p137_patd/pd05_struct_always']=f'''// § {L}
// case pd05: a module packed-array typedef of a struct read in always_comb
module top(input logic [5:0] i, output logic o);
  typedef struct packed {{ logic a; logic [1:0] b; }} s_t;
  typedef s_t [1:0] sa_t;
  sa_t v;
  assign v = i;
  always_comb o = v[1].a;
endmodule
'''
C['p137_patd/pd06_pkg_enum_localparam']=f'''// § {L}
// case pd06: a package packed-array enum typedef as a sub-module localparam type
package ep6;
  typedef enum logic [1:0] {{K0, K1, K2}} k_t;
  typedef k_t [1:0] ka_t;
endpackage
module top(output logic [3:0] o);
  localparam ep6::ka_t INIT = {{ep6::K1, ep6::K2}};
  assign o = INIT;
endmodule
'''
C['p137_patd/pd07_import_struct']=f'''// § {L}
// case pd07: a package packed-array struct typedef used through a wildcard import
package sp7;
  typedef struct packed {{ logic x; logic y; }} s_t;
  typedef s_t [2:0] sa_t;
endpackage
module top(output logic [5:0] o);
  import sp7::*;
  sa_t v;
  assign v = 6'h2A;
  assign o = v;
endmodule
'''
L='aliasCloneTakesTargetFile137'
C['p137_aliasfile/al04_two_dims']=f'''// § {L}
// case al04: an alias with two unpacked dimensions over a package struct
package ap4;
  typedef struct packed {{ logic k; logic m; }} a;
  typedef a b[1:0][2:0];
endpackage
module top();
  ap4::b v;
endmodule
'''
C['p137_aliasfile/al05_two_modules']=f'''// § {L}
// case al05: a package alias used by two modules
package ap5;
  typedef struct packed {{ logic k; }} a;
  typedef a b[3:0];
endpackage
module m1(); ap5::b v1; endmodule
module top(); ap5::b v2; m1 u(); endmodule
'''
C['p137_aliasfile/al06_union_pkg']=f'''// § {L}
// case al06: an unpacked alias of a package union typedef
package ap6;
  typedef union packed {{ logic [1:0] p; logic [1:0] q; }} u;
  typedef u ub[2];
endpackage
module top();
  ap6::ub v;
endmodule
'''
L='defNetScopedPkgArrTdShares137'
C['p137_scopedarrtd/sd04_struct_two_lines']=f'''// § {L}
// case sd04: two nets of a package-scoped struct array typedef on separate lines
package sp8;
  typedef struct packed {{ logic x; logic y; }} a;
  typedef a b[2:0];
endpackage
module dut(output o);
  sp8::b c;
  sp8::b d;
  assign c[0].x = 1;
  assign d[0].y = c[0].x;
  assign o = d[0].y;
endmodule
'''
C['p137_scopedarrtd/sd05_bit_elem']=f'''// § {L}
// case sd05: a package-scoped array typedef with a bit-vector element
package sp9;
  typedef bit [7:0] b[3];
endpackage
module dut(output logic [7:0] o);
  sp9::b c;
  assign c[1] = 8'h11;
  assign o = c[1];
endmodule
'''
C['p137_scopedarrtd/sd06_odd_bounds']=f'''// § {L}
// case sd06: a package-scoped array typedef with non-zero bounds
package spa;
  typedef struct packed {{ logic z; }} a;
  typedef a b[5:2];
endpackage
module dut(output logic o);
  spa::b c;
  assign c[3].z = 1'b1;
  assign o = c[3].z;
endmodule
'''
L='constCallNameSpan137'
C['p137_callspan/cs05_two_args']=f'''// § {L}
// case cs05: a two-argument call in a generate-if condition
module top(output logic [3:0] o);
  function automatic int mx(input int a, input int b); return a > b ? a : b; endfunction
  if (mx(2, 3) > 2) begin : g
    assign o = 4'd3;
  end else begin : h
    assign o = 4'd4;
  end
endmodule
'''
C['p137_callspan/cs06_genif_in_gencase']=f'''// § {L}
// case cs06: a call in a generate-if condition inside a generate-case item
module top #(parameter int M = 1) (output logic [3:0] o);
  function automatic int f(input int x); return x * 3; endfunction
  case (M)
    1: begin : c1
      if (f(M) == 3) begin : g
        assign o = 4'd7;
      end else begin : h
        assign o = 4'd8;
      end
    end
    default: begin : cd
      assign o = 4'd0;
    end
  endcase
endmodule
'''
C['p137_callspan/cs07_sysfunc_arg']=f'''// § {L}
// case cs07: a call whose argument is a system function, in a generate-if condition
module top(output logic [3:0] o);
  function automatic int f(input int x); return x; endfunction
  if (f($bits(o)) > 1) begin : g
    assign o = 4'd1;
  end
endmodule
'''
L='unknownParamOperandFile133'
C['p133_unkfile/uk05_unary']=f'''// § {L}
// case uk05: an X parameter under a unary minus
module top(output int o);
   parameter P = 'x;
   localparam int C = -P;
   assign o = C;
endmodule
'''
C['p133_unkfile/uk06_typed_vec_xor']=f'''// § {L}
// case uk06: a typed 4-state X parameter under an xor
module top(output logic [3:0] o);
   parameter logic [3:0] P = 'x;
   localparam logic [3:0] C = P ^ 4'h3;
   assign o = C;
endmodule
'''
C['p133_unkfile/uk07_two_unknown_add']=f'''// § {L}
// case uk07: two X operands under an addition, typed int
module top(output int o);
   parameter P = 'x;
   parameter Q = 'z;
   localparam int C = P + Q;
   assign o = C;
endmodule
'''
L='unsignedScalarVecTsAtKeyword137'
C['p137_defwire/dw04_param_sub']=f'''// § {L} (refinement R11V137_DEFWIRE_OFF)
// case dw04: a wire logic unsigned body net in a parameterized sub-module
module sub #(parameter int P = 1) (input logic a, output logic b);
  wire logic unsigned w;
  assign w = a;
  assign b = w;
endmodule
module top(input logic a, output logic b); sub #(.P(2)) u(.a(a), .b(b)); endmodule
'''
C['p137_defwire/dw05_attr_wand']=f'''// § {L} (refinement R11V137_DEFWIRE_OFF)
// case dw05: an attributed wand logic unsigned body net
module top(input logic a, output logic b);
  (* keep *) wand logic unsigned k;
  assign k = a;
  assign b = k;
endmodule
'''
# dw06 (a net read before its declaration) was dropped: not legal SV (slang rejects it)
L='pureVirtProtoSpan137'
C['p137_purevirt/pv05_module_protected_func']=f'''// § {L} (refinement R11V137_PVQUAL_OFF)
// case pv05: a pure virtual protected function with an argument in a module-scoped class
module top();
  virtual class Mv;
    pure virtual protected function void h(int a);
  endclass
endmodule
'''
C['p137_purevirt/pv06_param_class']=f'''// § {L} (refinement R11V137_PVQUAL_OFF)
// case pv06: a pure virtual protected function in a parameterized class
virtual class Pc #(int N = 2);
  pure virtual protected function logic [N-1:0] m();
endclass
module top(); endmodule
'''
for k,v in C.items():
    d=os.path.join(B,k); os.makedirs(d,exist_ok=True)
    open(os.path.join(d,'dut.sv'),'w').write(v)
print(len(C),'cases')
