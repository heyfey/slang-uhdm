#!/usr/bin/env python3
import os, sys
D = sys.argv[1]
os.makedirs(D, exist_ok=True)
F = {}

F['f01_tp2state_pk'] = """
module ch #(parameter type T = bit [7:0]) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f02_tp4state_pk'] = """
module ch #(parameter type T = logic [7:0]) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f03_tpenum_pk'] = """
package p; typedef enum logic [2:0] {A,B} e_t; endpackage
module ch #(parameter type T = p::e_t) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f04_tpstruct_pk'] = """
package p; typedef struct packed {logic [3:0] a; logic [3:0] b;} s_t; endpackage
module ch #(parameter type T = p::s_t) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f05_tp_pk_init'] = """
module ch #(parameter type T = logic [7:0]) (output logic s);
  T [1:0] d = '0; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f06_tp_pk_genblk'] = """
module ch #(parameter type T = logic [7:0]) (output logic s);
  logic [1:0] acc;
  for (genvar g = 0; g < 2; g++) begin : gb
    T [1:0] d; assign acc[g] = |{d};
  end
  assign s = |acc;
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f07_tp_pk_iface'] = """
interface itf #(parameter type T = logic [7:0]) ();
  T [1:0] d;
endinterface
module top; itf i0(); endmodule
"""
F['f08_tp_pk_in_ovr'] = """
package p; typedef logic [7:0] l_t; endpackage
module ch #(parameter type T = logic) (input T [1:0] d, output logic s);
  assign s = |{d};
endmodule
module top;
  logic s; logic [1:0][7:0] w;
  ch #(.T(p::l_t)) i0(.d(w), .s(s));
endmodule
"""
F['f09_typedef_of_typeparam_pk'] = """
module ch #(parameter type T = logic [7:0]) (output logic s);
  typedef T ali_t;
  ali_t [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f10_localenum_pk'] = """
module ch (output logic s);
  typedef enum logic [2:0] {A,B} e_t;
  e_t [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f11_pkgenum_unqual_pk'] = """
package p; typedef enum logic [2:0] {A,B} e_t; endpackage
module ch import p::*; (output logic s);
  e_t [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f12_pkgenum_scoped_pk'] = """
package p; typedef enum logic [2:0] {A,B} e_t; endpackage
module ch (output logic s);
  p::e_t [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f13_regtypedef_pk'] = """
module ch (output logic s);
  typedef reg [7:0] r_t;
  r_t [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f14_tp_of_tp_pk'] = """
module inner #(parameter type U = logic) (output logic s);
  U [1:0] d; assign s = |{d};
endmodule
module ch #(parameter type T = logic [7:0]) (output logic s);
  inner #(.U(T)) i1(.s(s));
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f15_tp_pk_and_unp'] = """
module ch #(parameter type T = logic [7:0]) (output logic s);
  T [1:0] d [2]; assign s = |{d[0]};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f16_tp_pk_toplevel'] = """
module top #(parameter type T = logic [7:0]) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
"""
F['f21_tpscalar_pk'] = """
module ch #(parameter type T = logic) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f22_tp_ovr_enum_pk'] = """
package p; typedef enum logic [2:0] {A,B} e_t; endpackage
module ch #(parameter type T = logic) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch #(.T(p::e_t)) i0(.s(s)); endmodule
"""
F['f23_vectortypedef_pk'] = """
module ch (output logic s);
  typedef logic [7:0] l_t;
  l_t [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['f24_structtypedef_pk'] = """
module ch (output logic s);
  typedef struct packed {logic [3:0] a; logic [3:0] b;} s_t;
  s_t [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
# ---- law C (K9) faces: a local net typed by a typedef used as a child's `type` arg
F['f30_k9_ansi_typearg'] = """
module ch #(parameter type T = logic) (input T d, output logic s);
  assign s = |{d};
endmodule
module top (input logic clk, output logic s);
  typedef logic [7:0] l_t;
  l_t n;
  ch #(.T(l_t)) i0(.d(n), .s(s));
endmodule
"""
F['f31_k9_nonansi_typearg'] = """
module ch #(parameter type T = logic) (input T d, output logic s);
  assign s = |{d};
endmodule
module top (clk, s);
  input logic clk; output logic s;
  typedef logic [7:0] l_t;
  l_t n;
  ch #(.T(l_t)) i0(.d(n), .s(s));
endmodule
"""
F['f32_k9_ansi_typearg_struct'] = """
package p; typedef struct packed {logic [3:0] a; logic [3:0] b;} s_t; endpackage
module ch #(parameter type T = logic) (input T d, output logic s);
  assign s = |{d};
endmodule
module top (input logic clk, output logic s);
  p::s_t n;
  ch #(.T(p::s_t)) i0(.d(n), .s(s));
endmodule
"""
F['f33_k9_ansi_typearg_unpdim'] = """
module ch #(parameter type T = logic) (input T d, output logic s);
  assign s = |{d};
endmodule
module top (input logic clk, output logic s);
  typedef logic [7:0] l_t;
  l_t n [2];
  ch #(.T(l_t)) i0(.d(n[0]), .s(s));
endmodule
"""
F['f34_k9_iface_typearg'] = """
module ch #(parameter type T = logic) (input T d, output logic s);
  assign s = |{d};
endmodule
interface itf (output logic s);
  typedef logic [7:0] l_t;
  l_t n;
  ch #(.T(l_t)) i0(.d(n), .s(s));
endinterface
module top; logic s; itf i0(.s(s)); endmodule
"""
F['f35_k9_ansi_empty_typearg'] = """
module ch #(parameter type T = logic) (input T d, output logic s);
  assign s = |{d};
endmodule
module top ();
  logic s;
  typedef logic [7:0] l_t;
  l_t n;
  ch #(.T(l_t)) i0(.d(n), .s(s));
endmodule
"""
F['f36_k9_ansi_typearg_init'] = """
module ch #(parameter type T = logic) (input T d, output logic s);
  assign s = |{d};
endmodule
module top (input logic clk, output logic s);
  typedef logic [7:0] l_t;
  l_t n = '0;
  ch #(.T(l_t)) i0(.d(n), .s(s));
endmodule
"""
F['f37_k9_ansi_typearg_enum'] = """
package p; typedef enum logic [2:0] {A,B} e_t; endpackage
module ch #(parameter type T = logic) (input T d, output logic s);
  assign s = |{d};
endmodule
module top (input logic clk, output logic s);
  p::e_t n;
  ch #(.T(p::e_t)) i0(.d(n), .s(s));
endmodule
"""
F['f38_k9_ansi_typearg_pkdim'] = """
module ch #(parameter type T = logic) (input T d, output logic s);
  assign s = |{d};
endmodule
module top (input logic clk, output logic s);
  typedef logic [7:0] l_t;
  l_t [1:0] n;
  ch #(.T(l_t)) i0(.d(n[0]), .s(s));
endmodule
"""
for k, v in F.items():
    open(os.path.join(D, k + '.sv'), 'w').write(v.lstrip())
print(len(F), 'faces written to', D)
