#!/usr/bin/env python3
"""gen_adv.py: third batch, adversarial shapes aimed at each law's trigger conditions (macro spans, trailing indexed
part-selects, operation base indices, TAB continuation lines, nested qualified selects, named-argument calls, arrays of
ports, packed dimensions on type parameters, generate-scope net binding)."""
import os
B=os.path.join(os.path.dirname(os.path.abspath(__file__)),'..','cases')
C={}
PK='''package p;
  typedef struct packed { logic valid; logic [3:0] sat; } e_t;
  typedef struct packed { e_t f; logic [1:0] tag; } w_t;
endpackage
'''
C['p133_unkfile/uk08_macro_operand']=('''// § unknownParamOperandFile133
// case uk08: the X operand is written through a macro
`define PX P
module top(output int o);
   parameter P = 'x;
   parameter Q = 3;
   localparam int C = `PX / Q;
   assign o = C;
endmodule
''',{})
C['p133_trailidx/tx06_trailing_ips_var']=('''// § hpTrailSelIdxNamesByPath133
// case tx06: a trailing INDEXED part-select with a variable start
'''+PK+'''module dut(input logic [1:0] r, input logic [1:0] i, input logic [15:0] flat, output logic [1:0] o);
  p::w_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r].f.sat[i +: 2];
endmodule
''',{})
C['p133_hpmid/hm06_base_index_op']=('''// § hpBaseSelMidMemberBare133
// case hm06: the base select's index is an operation
'''+PK+'''module dut(input logic r, input logic [15:0] flat, output logic o);
  p::w_t [1:0] tbl;
  assign tbl = flat;
  assign o = tbl[r + 1'b0].f.valid;
endmodule
''',{})
C['p133_hpmid/hm07_nb_lvalue_member_idx']=('''// § hpBaseSelMidMemberBare133
// case hm07: a middle-member path as a nonblocking lvalue with a trailing select
'''+PK+'''module dut(input logic clk, input logic [1:0] r, input logic [1:0] i, output logic [15:0] flat);
  p::w_t [1:0] tbl;
  always_ff @(posedge clk) tbl[r].f.sat[i] <= 1'b1;
  assign flat = tbl;
endmodule
''',{})
BODY='module helper(input logic x, output logic z);\n  assign z = x;\nendmodule\n'
TOP='module top(input logic [3:0] a, output logic [3:0] y);\n  assign y = a + 1;\nendmodule\n'
L='includeInactiveTabNotText141v'
C['p141_inctabact/it05_skipped_continuation']=(f'// § {L}\n// case it05: a skipped branch holding a multi-line define whose continuation line starts with a TAB\n`include "defs.svh"\n`include "body.svh"\n'+TOP,
  {'defs.svh':'`ifdef NOPE\n`define W (1 + \\\n\t2)\n`endif\n','body.svh':BODY})
C['p141_inctabact/it06_active_continuation']=(f'// § {L}\n// case it06: an ACTIVE multi-line define whose continuation line starts with a TAB\n`include "defs.svh"\n`include "body.svh"\n'+TOP,
  {'defs.svh':'`define W (1 + \\\n\t2)\n','body.svh':BODY})
C['p141_inctabact/it07_skipped_inner_else']=(f'// § {L}\n// case it07: an inner ifdef/else inside a skipped outer branch, TAB-led lines in both inner branches\n`include "defs.svh"\n`include "body.svh"\n'+TOP,
  {'defs.svh':'`ifdef NOPE\n`ifdef ALSO\n\t`define V 1\n`else\n\t`define V 2\n`endif\n`endif\n','body.svh':BODY})
C['p141_inctabact/it08_elsif_taken_tab']=(f'// § {L}\n// case it08: a false ifdef, then a TAKEN elsif whose branch holds a TAB-led define\n`define TWO\n`include "defs.svh"\n`include "body.svh"\n'+TOP,
  {'defs.svh':'`ifdef NOPE\n`define W 1\n`elsif TWO\n\t`define W 2\n`endif\n','body.svh':BODY})
PK3='package p;\n  parameter logic [15:0] A = 16\'h1234;\n  parameter int K = 2;\nendpackage\n'
L='ipsQualBaseRangeSpan141v'
C['p141_ipsqual/iq05_in_concat']=(f'''// § {L}
// case iq05: a qualified indexed part-select nested in a concatenation of a parameter default
{PK3}module top #(parameter logic [7:0] P = {{p::A[0 +: 4], 4'h0}}) (output logic [7:0] o);
  assign o = P;
endmodule
''',{})
C['p141_ipsqual/iq06_minus_localparam']=(f'''// § {L}
// case iq06: a qualified indexed part-select with -: in a body localparam
{PK3}module top(output logic [3:0] o);
  localparam logic [3:0] L = p::A[11 -: 4];
  assign o = L;
endmodule
''',{})
L='constCallNameSpan137'
C['p137_callspan/cs08_named_arg']=(f'''// § {L}
// case cs08: a call with a named argument in a generate-if condition
module top(output logic [3:0] o);
  function automatic int f(input int x, input int y = 1); return x + y; endfunction
  if (f(.x(2)) == 3) begin : g
    assign o = 4'd9;
  end
endmodule
''',{})
L='emptyNamedConnLowConnAtDecl137'
C['p137_emptyconn/en05_unpacked_port']=(f'''// § {L}
// case en05: an explicitly empty named connection of an unpacked-array output port
module sub(input logic a, output logic [1:0] b [2], output logic c);
  assign b[0] = {{a, a}}; assign b[1] = 2'b00;
  assign c = a;
endmodule
module top(input logic x, output logic y);
  sub u(.a(x), .b(), .c(y));
endmodule
''',{})
L='taggedUnionElabSpan137'
C['p137_tagged/tu04_port_type']=(f'''// § {L}
// case tu04: a tagged packed union typedef as a sub-module port type
typedef union tagged packed {{
  logic [3:0] m;
  logic [3:0] n;
}} tu_t;
module sub(input tu_t x, output logic [3:0] o); assign o = x.m; endmodule
module top(input logic [4:0] i, output logic [3:0] o); sub u(.x(i), .o(o)); endmodule
''',{})
L='defNetTypeParamDefault137'
C['p137_defnettp/tp05_packed_dim_on_tp']=(f'''// § {L}
// case tp05: a definition net typed by a type parameter with an added packed dimension
module sub #(parameter type T = logic) (output logic [3:0] o);
  T [3:0] v;
  assign v = 4'h6;
  assign o = v;
endmodule
module top(output logic [3:0] o); sub u(.o(o)); endmodule
''',{})
L='aliasCloneTakesTargetFile137'
C['p137_aliasfile/al07_alias_in_include']=(f'''// § {L}
// case al07: the alias typedef sits in an included file, its struct target in dut.sv
package ai;
  typedef struct packed {{ logic k; }} a;
`include "alias.svh"
endpackage
module top();
  ai::b v;
endmodule
''',{'alias.svh':'  typedef a b[1:0];\n'})
# sp05 (a -: part-select in a net declaration range) was dropped: not legal SV (Surelog and slang both reject it)
L='packedArrTdElemRefName137'
C['p137_patd/pd08_func_return']=(f'''// § {L}
// case pd08: a packed-array enum typedef as a function return type
module top(output logic [3:0] o);
  typedef enum logic [1:0] {{Z0, Z1, Z2}} z_t;
  typedef z_t [1:0] za_t;
  function automatic za_t mk(); return {{Z1, Z2}}; endfunction
  assign o = mk();
endmodule
''',{})
C['p139_nda/nd09_genblock']=('''// § ndaLeftmostLeafElab139
// case nd09: a net declaration assignment inside a generate block
module top(input logic a, input logic b, output logic y);
  if (1) begin : g
    wire w = a & b;
    assign y = w;
  end
endmodule
''',{})
C['p139_ca/ca18_genblock_param_bitsel']=('''// § caLhsDefNetUnlessOpRhs139
// case ca18: a bit-select of a package parameter assigned inside a generate block
package pg; parameter logic [3:0] A = 4'b0101; endpackage
module top(output logic y);
  if (1) begin : g
    assign y = pg::A[2];
  end
endmodule
''',{})
C['p139_port/pc05_genblock_op']=('''// § connLeftmostLeafElab139
// case pc05: an operation actual on an instance inside a generate block
module sub(input logic a, output logic y); assign y = a; endmodule
module top(input logic p, input logic q, output logic y);
  if (1) begin : g
    sub u(.a(p ^ q), .y(y));
  end
endmodule
''',{})
for k,(v,extra) in C.items():
    d=os.path.join(B,k); os.makedirs(d,exist_ok=True)
    for fn,t in extra.items(): open(os.path.join(d,fn),'w').write(t)
    open(os.path.join(d,'dut.sv'),'w').write(v)
print(len(C),'cases')
