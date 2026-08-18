#!/usr/bin/env python3
"""r10rgg8/gen_grid.py -- MEASUREMENT ONLY.  Writes cells/<name>/dut.sv.

THE QUESTION every cell answers: when a cont-assign RHS is a call to a user
function with a NON-CONSTANT actual, does Surelog's netlist elaboration FOLD
that RHS to a constant (and with WHAT value / size / encoding / LOCATION), or
does it keep the func_call?

Each cell is self-contained: module `m` holds the function and the site under
test, `dut` instantiates it.  Cells never spell the four slang-fenced corpus
row names.
"""
import os, sys

HERE = os.path.dirname(os.path.abspath(__file__))
CELLS = os.path.join(HERE, 'cells')

# ---------------------------------------------------------------- templates
# `m` takes a non-constant 8-bit input `a`; PD is the Rggen `PRE_DECODE`
# analogue.  The site under test is written by each cell.
def mod(body, ports='input logic [7:0] a, output logic o', params='parameter bit PD = 0',
        extra=''):
    return f"""module m #({params}) ({ports});
{extra}{body}
endmodule
"""

def dut(inst='  m u0(.a(a), .o(o));\n', ports='input logic [7:0] a, output logic o',
        pre=''):
    return f"""{pre}module dut({ports});
{inst}endmodule
"""

# The canonical const-guarded body.  `taken_ret` is what the ELSE arm returns.
def guarded(ret_else="'1", ret_type='logic', if_arm=None, fname='f'):
    if if_arm is None:
        if_arm = """      logic [7:0] b;
      b = 8'h10;
      return (address >= b);"""
    return f"""  function automatic {ret_type} {fname}(
    logic [7:0] address
  );
    if (PD) begin
{if_arm}
    end
    else begin
      return {ret_else};
    end
  endfunction
"""

CELLS_SPEC = {}

def add(name, text):
    CELLS_SPEC[name] = text

# ============================ A. THE Rggen SHAPE, return-value variants
for nm, ret, rt in [
    ('a_lit1',      "'1",              'logic'),
    ('a_lit0',      "'0",              'logic'),
    ('a_dec3',      "3",               'logic [7:0]'),
    ('a_sized',     "8'h2a",           'logic [7:0]'),
    ('a_param',     "P",               'logic [7:0]'),
    ('a_concat',    "{2'b10, 2'b11}",  'logic [3:0]'),
    ('a_bitret',    "'1",              'bit'),
    ('a_intret',    "'1",              'int'),
    ('a_vecret',    "'1",              'logic [7:0]'),
    ('a_signedret', "'1",              'logic signed [7:0]'),
    ('a_lit1_i',    "'1",              'logic'),   # instance count 2, see below
]:
    ports = 'input logic [7:0] a, output logic o' if rt in ('logic','bit') else \
            'input logic [7:0] a, output logic [31:0] o'
    body = "  assign o = f(a);\n" + guarded(ret, rt)
    add(nm, mod(body, ports=ports, params='parameter bit PD = 0, parameter int P = 5')
        + dut(ports=('input logic [7:0] a, output logic o' if rt in ('logic','bit')
                     else 'input logic [7:0] a, output logic [31:0] o')))

# a_lit1_i2 / a_lit1_i3 -- 2 and 3 instances of the SAME definition
for n in (2, 3):
    body = "  assign o = f(a);\n" + guarded()
    inst = ''.join(f"  m u{i}(.a(a), .o(w[{i}]));\n" for i in range(n))
    add(f'a_inst{n}', mod(body) + dut(
        inst=f"  logic [{n-1}:0] w;\n" + inst + f"  assign o = |w;\n"))

# ============================ B. BODY SHAPES
add('b_taken_reads', mod("  assign o = f(a);\n" + guarded(),
                         params='parameter bit PD = 1, parameter int P = 5') + dut())
add('b_if_arm_lit', mod("  assign o = f(a);\n" + guarded(
        ret_else="(address >= 8'h10)", if_arm="      return '1;"),
        params='parameter bit PD = 1, parameter int P = 5') + dut())
add('b_else_reads', mod("  assign o = f(a);\n" + guarded(ret_else="(address >= 8'h10)"))
    + dut())
add('b_ternary', mod("""  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    return PD ? (address >= 8'h10) : '1;
  endfunction
""") + dut())
add('b_case_param', mod("""  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    case (PD)
      1'b0: return '1;
      default: return (address >= 8'h10);
    endcase
  endfunction
""") + dut())
add('b_loop_ret', mod("""  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      for (int i = 0; i < 4; i++) begin
        return '1;
      end
      return '0;
    end
  endfunction
""") + dut())
add('b_loop_noret', mod("""  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    logic r;
    r = '0;
    if (PD) begin
      r = (address >= 8'h10);
    end
    else begin
      for (int i = 0; i < 4; i++) begin
        r = '1;
      end
    end
    return r;
  endfunction
""") + dut())
add('b_nested_call', mod("""  assign o = f(a);
  function automatic logic g();
    return '1;
  endfunction
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return g();
    end
  endfunction
""") + dut())
add('b_nested_call_arg', mod("""  assign o = f(a);
  function automatic logic g(logic [7:0] x);
    return '1;
  endfunction
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return g(address);
    end
  endfunction
""") + dut())
add('b_recursion', mod("""  assign o = f(a);
  function automatic logic [7:0] f(logic [7:0] address);
    if (address == 0) begin
      return 8'h1;
    end
    else begin
      return f(address - 1);
    end
  endfunction
""", ports='input logic [7:0] a, output logic [7:0] o') +
    dut(ports='input logic [7:0] a, output logic [7:0] o'))
add('b_noelse', mod("""  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
  endfunction
""") + dut())
add('b_fname_assign', mod("""  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      f = (address >= 8'h10);
    end
    else begin
      f = '1;
    end
  endfunction
""") + dut())
add('b_read_modsig', mod("""  logic w;
  assign w = '1;
  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return w;
    end
  endfunction
""") + dut())
add('b_read_param', mod("""  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return P[0];
    end
  endfunction
""", params='parameter bit PD = 0, parameter int P = 5') + dut())
add('b_bits_of_arg', mod("""  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return ($bits(address) == 8);
    end
  endfunction
""") + dut())
add('b_clog2_of_arg', mod("""  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return ($clog2(address) > 0);
    end
  endfunction
""") + dut())
add('b_sideeffect', mod("""  logic sticky;
  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      sticky = 1'b1;
      return '1;
    end
  endfunction
""") + dut())
add('b_multiret', mod("""  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
      return '0;
    end
  endfunction
""") + dut())
add('b_localdecl', mod("""  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      logic [7:0] t;
      t = 8'h1;
      return t[0];
    end
  endfunction
""") + dut())
add('b_localparam', mod("""  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    localparam logic K = '1;
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return K;
    end
  endfunction
""") + dut())
add('b_static_fn', mod("""  assign o = f(a);
  function static logic f(logic [7:0] address);
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction
""") + dut())
add('b_outformal', mod("""  logic ex;
  assign o = f(a, ex);
  function automatic logic f(logic [7:0] address, output logic q);
    q = '0;
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction
""") + dut())
add('b_twoargs_mixed', mod("""  assign o = f(a, 8'h3);
  function automatic logic f(logic [7:0] address, logic [7:0] k);
    if (PD) begin
      return (address >= k);
    end
    else begin
      return '1;
    end
  endfunction
""") + dut())
add('b_arg_used_untaken_only', mod("""  assign o = f(a);
  function automatic logic f(logic [7:0] address);
    logic [7:0] t;
    t = address;
    if (PD) begin
      return (t >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction
""") + dut())

# ============================ C. THE ARG SHAPE
add('c_hierpath_actual', """interface bus_t;
  logic [7:0] address;
endinterface
""" + mod("""  assign o = f(bus_if.address);
""" + guarded(), ports='bus_t bus_if, output logic o') + """module dut(input logic [7:0] a, output logic o);
  bus_t bus_if();
  assign bus_if.address = a;
  m u0(.bus_if(bus_if), .o(o));
endmodule
""")
add('c_select_actual', mod("  assign o = f({4'h0, a[3:0]});\n" + guarded()) + dut())
add('c_net_actual', mod("""  logic [7:0] n;
  assign n = a;
  assign o = f(n);
""" + guarded()) + dut())
add('c_allconst_actual', mod("  assign o = f(8'h5);\n" + guarded()) + dut())
add('c_operand_call', mod("  assign o = f(a) | 1'b0;\n" + guarded()) + dut())

# ============================ D. THE CONTEXT
add('d_gen_ca', mod("""  generate
    if (1) begin : g
      assign o = f(a);
    end
  endgenerate
""" + guarded()) + dut())
add('d_proc', mod("""  always_comb begin
    o = f(a);
  end
""" + guarded()) + dut())
add('d_port', mod("""  logic q;
  n u1(.x(f(a)), .y(q));
  assign o = q;
""" + guarded(), extra="") + """module n(input logic x, output logic y);
  assign y = x;
endmodule
""" + dut())
add('d_paraminit', mod("""  localparam logic Q = 1'b1;
  assign o = f(a) & Q;
""" + guarded()) + dut())
add('d_varinit', mod("""  logic v = f(a);
  assign o = v;
""" + guarded()) + dut())
add('d_ifcond', mod("""  assign o = f(a);
  generate
    if (PD) begin : g1
      logic z;
    end
  endgenerate
""" + guarded()) + dut())

# ============================ E. FUNCTION LOCATION
add('e_pkgfunc', """package pk;
  function automatic logic pf(logic [7:0] address);
    if (1'b0) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction
endpackage
""" + mod("""  assign o = pk::pf(a);
""") + dut())
add('e_pkgfunc_import', """package pk2;
  function automatic logic pf2(logic [7:0] address);
    if (1'b0) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction
endpackage
""" + """module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  import pk2::*;
  assign o = pf2(a);
endmodule
""" + dut())
add('e_classmethod', """class C;
  function automatic logic cm(logic [7:0] address);
    if (1'b0) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end
  endfunction
endclass
""" + """module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  C c = new();
  assign o = c.cm(a);
endmodule
""" + dut())

# ============================ F. THE PARAM AXIS
for pv, nm in ((0, 'f_pd0'), (1, 'f_pd1')):
    add(nm, mod("  assign o = f(a);\n" + guarded(),
                params=f'parameter bit PD = {pv}, parameter int P = 5') + dut())
# PD overridden at the instance
add('f_override1', mod("  assign o = f(a);\n" + guarded()) +
    dut(inst="  m #(.PD(1)) u0(.a(a), .o(o));\n"))
add('f_override0', mod("  assign o = f(a);\n" + guarded(),
                       params='parameter bit PD = 1') +
    dut(inst="  m #(.PD(0)) u0(.a(a), .o(o));\n"))
# TWO instances with DIFFERENT PD -- the per-instance discriminator
add('f_split', mod("  assign o = f(a);\n" + guarded()) +
    dut(inst="""  logic w0, w1;
  m #(.PD(0)) u0(.a(a), .o(w0));
  m #(.PD(1)) u1(.a(a), .o(w1));
  assign o = w0 ^ w1;
"""))

# ============================ G. THE HIER/ARG-SHAPE CELLS
#   h_modport / h_intlhs / h_full / h_ifparam / h_mp_noports isolate the MODPORT
#   as the one hierarchical actual Surelog's decodeHierPath values;
#   h_arr / h_struct / h_submod / h_callarg are the other actual shapes.
_GUARD8 = """    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return '1;
    end"""

add('h_modport', """interface bus_t;
  logic [7:0] address;
  modport slave (input address);
endinterface
module m #(parameter bit PD = 0) (bus_t.slave bus_if, output logic o);
  assign o = f(bus_if.address);
  function automatic logic f(
    logic [7:0] address
  );
    if (PD) begin
      logic [7:0] b;
      b = 8'h10;
      return (address >= b);
    end
    else begin
      return '1;
    end
  endfunction
endmodule
module dut(input logic [7:0] a, output logic o);
  bus_t bus_if();
  assign bus_if.address = a;
  m u0(.bus_if(bus_if), .o(o));
endmodule
""")

add('h_intlhs', """interface bus_t;
  logic [7:0] address;
endinterface
module m #(parameter bit PD = 0) (bus_t bus_if, output logic o);
  logic inside_range;
  assign inside_range = f(bus_if.address);
  assign o = inside_range;
  function automatic logic f(
    logic [7:0] address
  );
    if (PD) begin
      logic [7:0] b;
      b = 8'h10;
      return (address >= b);
    end
    else begin
      return '1;
    end
  endfunction
endmodule
module dut(input logic [7:0] a, output logic o);
  bus_t bus_if();
  assign bus_if.address = a;
  m u0(.bus_if(bus_if), .o(o));
endmodule
""")

add('h_full', """interface bus_t #(parameter int ADDRESS_WIDTH = 16);
  logic [ADDRESS_WIDTH-1:0] address;
  modport slave (input address);
endinterface
module m #(parameter int ADDRESS_WIDTH = 8, parameter bit PD = 0)
  (bus_t.slave bus_if, output logic o);
  logic inside_range;
  assign inside_range = f(bus_if.address);
  assign o = inside_range;
  function automatic logic f(
    logic [ADDRESS_WIDTH-1:0] address
  );
    if (PD) begin
      logic [ADDRESS_WIDTH-1:0] b;
      b = 8'h10;
      return (address >= b);
    end
    else begin
      return '1;
    end
  endfunction
endmodule
module dut(input logic [7:0] a, output logic o);
  bus_t #(.ADDRESS_WIDTH(8)) bus_if();
  assign bus_if.address = a;
  m #(.ADDRESS_WIDTH(8)) u0(.bus_if(bus_if), .o(o));
endmodule
""")

add('h_ifparam', """interface bus_t;
  logic [7:0] address;
endinterface
module m #(parameter bit PD = 0) (bus_t bus_if, output logic o);
  logic inside_range;
  assign inside_range = f(bus_if.address);
  assign o = inside_range;
  function automatic logic f(
    logic [7:0] address
  );
""" + _GUARD8 + """
  endfunction
endmodule
module dut(input logic [7:0] a, output logic o);
  bus_t bus_if();
  assign bus_if.address = a;
  m u0(.bus_if(bus_if), .o(o));
endmodule
""")

add('h_mp_noports', """interface bus_t;
  logic [7:0] address;
  modport slave (input address);
endinterface
module m #(parameter bit PD = 0) (bus_t.slave bus_if, output logic o);
  logic inside_range;
  assign inside_range = f(bus_if.address);
  assign o = inside_range;
  function automatic logic f(
    logic [7:0] address
  );
""" + _GUARD8 + """
  endfunction
endmodule
module dut(input logic [7:0] a, output logic o);
  bus_t bus_if();
  assign bus_if.address = a;
  m u0(.bus_if(bus_if), .o(o));
endmodule
""")

add('h_arr', """module m #(parameter bit PD = 0) (input logic [7:0] a[4], input int idx, output logic o);
  assign o = f(a[idx]);
  function automatic logic f(
    logic [7:0] address
  );
""" + _GUARD8 + """
  endfunction
endmodule
module dut(input logic [7:0] a[4], input int idx, output logic o);
  m u0(.a(a), .idx(idx), .o(o));
endmodule
""")

add('h_struct', """typedef struct packed { logic [7:0] addr; } s_t;
module m #(parameter bit PD = 0) (input s_t sv, output logic o);
  assign o = f(sv.addr);
  function automatic logic f(
    logic [7:0] address
  );
""" + _GUARD8 + """
  endfunction
endmodule
module dut(input s_t sv, output logic o);
  m u0(.sv(sv), .o(o));
endmodule
""")

add('h_submod', """module sub(output logic [7:0] q);
  assign q = 8'h20;
endmodule
module m #(parameter bit PD = 0) (output logic o);
  sub u_s();
  assign o = f(u_s.q);
  function automatic logic f(
    logic [7:0] address
  );
""" + _GUARD8 + """
  endfunction
endmodule
module dut(output logic o);
  m u0(.o(o));
endmodule
""")

add('h_callarg', """module m #(parameter bit PD = 0) (input logic [7:0] a, output logic o);
  assign o = f(g(a));
  function automatic logic [7:0] g(logic [7:0] x);
    return x + 1;
  endfunction
  function automatic logic f(
    logic [7:0] address
  );
""" + _GUARD8 + """
  endfunction
endmodule
module dut(input logic [7:0] a, output logic o);
  m u0(.a(a), .o(o));
endmodule
""")

# ============================ H. THE LITERAL x RETURN-TYPE SUB-GRID (64 cells)
# The clause-3 evidence: which literal FORMS Surelog's `get_value` can mask, and
# what width/encoding the folded constant ends up with.  Every cell assigns to
# the SAME 32-bit net, so a width that varies is provably the RETURN TYPE's.
_LITS = {"L_u1": "'1", "L_u0": "'0", "L_0": "0", "L_1": "1", "L_3": "3",
         "L_42": "42", "L_1b1": "1'b1", "L_8h2a": "8'h2a", "L_8d42": "8'd42",
         "L_8b101010": "8'b101010", "L_32hdead": "32'hdead", "L_4h5": "4'h5",
         "L_neg1": "-1", "L_8sd3": "8'sd3", "L_1d0": "1'd0", "L_2b11": "2'b11"}
_RTS = {"lg": "logic", "v8": "logic [7:0]", "it": "int", "bt": "bit"}
for _ln, _lv in _LITS.items():
    for _rn, _rv in _RTS.items():
        add(f"{_ln}_{_rn}", f"""module m #(parameter bit PD = 0) (input logic [7:0] a, output logic [31:0] o);
  assign o = f(a);
  function automatic {_rv} f(
    logic [7:0] address
  );
    if (PD) begin
      return (address >= 8'h10);
    end
    else begin
      return {_lv};
    end
  endfunction
endmodule
module dut(input logic [7:0] a, output logic [31:0] o);
  m u0(.a(a), .o(o));
endmodule
""")


def main():
    os.makedirs(CELLS, exist_ok=True)
    for name, text in sorted(CELLS_SPEC.items()):
        d = os.path.join(CELLS, name)
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, 'dut.sv'), 'wt') as fh:
            fh.write(text)
    print(f"wrote {len(CELLS_SPEC)} cells to {CELLS}")

if __name__ == '__main__':
    main()
