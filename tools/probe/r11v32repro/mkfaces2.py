#!/usr/bin/env python3
import os, sys
D = sys.argv[1]
os.makedirs(D, exist_ok=True)
F = {}
F['g01_tp_int_pk'] = """
module ch #(parameter type T = int) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['g02_tp_integer_pk'] = """
module ch #(parameter type T = integer) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['g03_tp_bitscalar_pk'] = """
module ch #(parameter type T = bit) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['g04_tp_signed_pk'] = """
module ch #(parameter type T = logic signed [7:0]) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['g05_tp_ovr_2state'] = """
package p; typedef bit [7:0] b_t; endpackage
module ch #(parameter type T = logic [7:0]) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch #(.T(p::b_t)) i0(.s(s)); endmodule
"""
F['g06_pkgvec_unqual_pk'] = """
package p; typedef logic [7:0] l_t; endpackage
module ch import p::*; (output logic s);
  l_t [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['g07_tp_nonansi_pk'] = """
module ch #(parameter type T = logic [7:0]) (s);
  output logic s;
  T [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['g08_tp_pk_out_port'] = """
module ch #(parameter type T = logic [7:0]) (output T [1:0] d, output logic s);
  assign s = 1'b0;
endmodule
module top; logic s; logic [1:0][7:0] w; ch i0(.d(w), .s(s)); endmodule
"""
F['g09_tp_pk_inout_port'] = """
module ch #(parameter type T = logic [7:0]) (inout T [1:0] d, output logic s);
  assign s = |{d};
endmodule
module top; logic s; wire [1:0][7:0] w; ch i0(.d(w), .s(s)); endmodule
"""
F['g10_tp_pk_two_dims'] = """
module ch #(parameter type T = logic [7:0]) (output logic s);
  T [1:0][2:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['g11_localenum_nodim'] = """
module ch (output logic s);
  typedef enum logic [2:0] {A,B} e_t;
  e_t d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['g12_tp_nodim_body'] = """
module ch #(parameter type T = logic [7:0]) (output logic s);
  T d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['g13_enum2state_pk'] = """
module ch (output logic s);
  typedef enum bit [1:0] {A,B} e_t;
  e_t [1:0] d; assign s = |{d};
endmodule
module top; logic s; ch i0(.s(s)); endmodule
"""
F['g14_tp_pk_multi_inst'] = """
package p; typedef logic [7:0] a_t; typedef logic [3:0] b_t; endpackage
module ch #(parameter type T = logic) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
module top;
  logic s;
  ch #(.T(p::a_t)) i0(.s(s));
  ch #(.T(p::b_t)) i1(.s(s));
endmodule
"""
F['g15_tp_pk_genfor_inst'] = """
module ch #(parameter type T = logic [7:0]) (output logic s);
  T [1:0] d; assign s = |{d};
endmodule
module top;
  logic [1:0] s;
  for (genvar g = 0; g < 2; g++) begin : gb
    ch i0(.s(s[g]));
  end
endmodule
"""
for k, v in F.items():
    open(os.path.join(D, k + '.sv'), 'w').write(v.lstrip())
print(len(F), 'faces written')
