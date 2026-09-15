#!/usr/bin/env python3
# r11u43 — THE GOLDEN GRID for the unsized fill at a target the raw-shape law
# does not reach.  One arm = one directory = one dut.sv with ONE module.
# Measurement-only.
import os, sys

ROOT = sys.argv[1] if len(sys.argv) > 1 else "/tmp/r11u43_g/grid"

STRUCT = """    typedef struct packed {
        logic [31:0] a;
        logic [15:0] b;
        logic [7:0]  c;
    } st_t;                       // 56-bit named struct
"""
TPARAM = """    localparam type my_t = struct packed {
        logic [31:0] a;
        logic [15:0] b;
        logic [7:0]  c;
    };                            // 56-bit struct TYPE PARAMETER
"""

ARMS = {}

def M(name, body, ports="(input logic clk)"):
    ARMS[name] = "module %s %s;\n%s\nendmodule\n" % (name, ports, body)

# ---- FAMILY A: the target shape, on a struct TYPE PARAMETER (the corpus row)
M("g01", TPARAM + "    my_t        s0;\n    assign s0 = '0;\n")
M("g02", TPARAM + "    my_t [2:0]  s1;\n    assign s1 = '0;\n")
M("g03", TPARAM + "    my_t [0:0]  s2;\n    assign s2 = '0;\n")
M("g04", TPARAM + "    my_t [1:0][2:0] s3;\n    assign s3 = '0;\n")
M("g05", TPARAM + "    my_t [2:0]  s4;\n    assign s4 = '1;\n")
M("g06", TPARAM + "    my_t [2:0]  s5;\n    assign s5 = 'x;\n")
M("g07", TPARAM + "    my_t [2:0]  s6;\n    assign s6 = 'z;\n")

# ---- FAMILY B: the same shapes on a NAMED TYPEDEF struct (not a type param)
M("g08", STRUCT + "    st_t        t0;\n    assign t0 = '0;\n")
M("g09", STRUCT + "    st_t [2:0]  t1;\n    assign t1 = '0;\n")
M("g10", STRUCT + "    st_t [2:0]  t2;\n    assign t2 = '1;\n")

# ---- FAMILY C: a packed array of a NON-struct named type
M("g11", "    typedef logic [7:0] b_t;\n    b_t       u0;\n    assign u0 = '0;\n")
M("g12", "    typedef logic [7:0] b_t;\n    b_t [2:0] u1;\n    assign u1 = '0;\n")
M("g13", "    localparam type b_t = logic [7:0];\n    b_t [2:0] u2;\n    assign u2 = '0;\n")

# ---- FAMILY D: an ANONYMOUS multi-dim packed logic (no named type at all)
M("g14", "    logic [55:0]      v0;\n    assign v0 = '0;\n")
M("g15", "    logic [2:0][7:0]  v1;\n    assign v1 = '0;\n")
M("g16", "    logic [2:0][7:0]  v2;\n    assign v2 = '1;\n")

# ---- FAMILY E: an anonymous INLINE packed struct declaration (no name)
M("g17", "    struct packed { logic [31:0] a; logic [23:0] b; } w0;\n    assign w0 = '0;\n")

# ---- FAMILY F: WRITE SITE — var vs net vs port vs gen scope
M("g18", TPARAM + "    var my_t [2:0] x0;\n    assign x0 = '0;\n")
M("g19", TPARAM + "    wire my_t [2:0] x1;\n    assign x1 = '0;\n")
M("g20", TPARAM + "    my_t [2:0] x2;\n    if (1) begin : gb\n        my_t [2:0] x3;\n        assign x3 = '0;\n    end\n")
M("g21", TPARAM + "    my_t [2:0] x4;\n    always_comb x4 = '0;\n")
M("g22", TPARAM + "    my_t [2:0] x5;\n    initial x5 = '0;\n")
M("g23", TPARAM + "    my_t [2:0] x6;\n    assign x6[1] = '0;\n")
M("g24", TPARAM + "    my_t [2:0] x7;\n    assign x7[1:0] = '0;\n")
M("g25", TPARAM + "    my_t [2:0] x8;\n    assign x8[0].a = '0;\n")
M("g26", TPARAM + "    my_t [2:0] x9;\n    localparam my_t [2:0] P = '0;\n    assign x9 = P;\n")

# ---- FAMILY G: PORT of the target shape (write site = a port declaration)
ARMS["g27"] = (
    "module g27 (input logic clk, output " +
    "logic [2:0][7:0] po);\n    assign po = '0;\nendmodule\n")
ARMS["g28"] = (
    "package pk;\n" + STRUCT.replace("    ", "  ") + "endpackage\n"
    "module g28 (input logic clk, output pk::st_t [2:0] po2);\n"
    "    assign po2 = '0;\nendmodule\n")

# ---- FAMILY H: UNPACKED array and dynamic-ish shapes (the fence's far side)
M("g29", TPARAM + "    my_t y0 [2:0];\n    assign y0[0] = '0;\n")
M("g30", "    logic [7:0] y1 [2:0];\n    assign y1[0] = '0;\n")

# ---- FAMILY I: packed array of ENUM / of a packed UNION
M("g31", "    typedef enum logic [7:0] { A, B } e_t;\n    e_t [2:0] z0;\n    assign z0 = '0;\n")
M("g32", "    typedef union packed { logic [7:0] a; logic [7:0] b; } un_t;\n"
         "    un_t [2:0] z1;\n    assign z1 = '0;\n")
M("g33", "    typedef enum logic [7:0] { A, B } e_t;\n    e_t z2;\n    assign z2 = '0;\n")

# ---- FAMILY J: a struct WHOSE MEMBER is itself a packed array (control:
#      the struct is the target, an array is only inside it)
M("g34", "    typedef struct packed { logic [2:0][7:0] m; } sa_t;\n"
         "    sa_t z3;\n    assign z3 = '0;\n")
M("g35", "    typedef struct packed { logic [2:0][7:0] m; } sa_t;\n"
         "    sa_t [1:0] z4;\n    assign z4 = '0;\n")

# ---- FAMILY K: the same target reached through a TYPEDEF OF THE ARRAY
M("g36", STRUCT + "    typedef st_t [2:0] arr_t;\n    arr_t z5;\n    assign z5 = '0;\n")
M("g37", "    typedef logic [2:0][7:0] pa_t;\n    pa_t z6;\n    assign z6 = '0;\n")

# ---- FAMILY L: width sweep on the packed-array target (does the WIDTH enter?)
M("g38", STRUCT + "    st_t [1:0] z7;\n    assign z7 = '0;\n")   # 112
M("g39", STRUCT + "    st_t [7:0] z8;\n    assign z8 = '0;\n")   # 448
M("g40", "    typedef struct packed { logic [3:0] a; } s4_t;\n"
         "    s4_t [1:0] z9;\n    assign z9 = '0;\n")            # 8 bits, < 64

# ---- FAMILY M: a NON-fill constant Rhs on the target shape (the control that
#      convicts the FILL, not the target)
M("g41", STRUCT + "    st_t [1:0] za;\n    assign za = 112'd0;\n")
M("g42", STRUCT + "    st_t [1:0] zb;\n    assign zb = 0;\n")
M("g43", STRUCT + "    st_t [1:0] zc;\n    assign zc = '{default:'0};\n")

for name, text in sorted(ARMS.items()):
    d = os.path.join(ROOT, name)
    os.makedirs(d, exist_ok=True)
    with open(os.path.join(d, "dut.sv"), "w") as f:
        f.write("// r11u43 grid arm %s\n" % name)
        f.write(text)
print(len(ARMS), "arms ->", ROOT)
