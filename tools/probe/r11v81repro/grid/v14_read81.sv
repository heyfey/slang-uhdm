// r11v81 adversarial arm v14 — a PACKAGE pattern with UNQUALIFIED setters,
// read out four ways: by a qualified name into a module localparam, by an
// imported bare name, as an instance override, and as a module parameter
// default.  The pattern's own home never changes; only the READ does.
package v14p;
  localparam PU = 5;
  localparam PH = 16'h5;
  localparam PD = 16'd5;
  typedef struct packed {
    logic [23:0] bail; logic [23:0] a; logic [23:0] b; logic [23:0] c;
  } t14;
  localparam t14 SRC = '{bail: 8'hxA, a: PU, b: PH, c: PD};
endpackage
module v14_read81 #(parameter v14p::t14 CDEF = v14p::SRC)
                   (output logic [23:0] o1, output logic [23:0] o2,
                    output logic [23:0] o3);
  import v14p::*;
  localparam v14p::t14 RQUAL = v14p::SRC;
  localparam v14p::t14 RBARE = SRC;
  assign o1 = CDEF.a ^ CDEF.b ^ CDEF.c;
  assign o2 = RQUAL.a ^ RQUAL.b ^ RQUAL.c;
  assign o3 = RBARE.a ^ RBARE.b ^ RBARE.c;
  v14_sink #(.R(v14p::SRC)) s1();
endmodule
module v14_sink #(parameter v14p::t14 R = '{default: 0}) (output logic [23:0] o);
  assign o = R.a;
endmodule
