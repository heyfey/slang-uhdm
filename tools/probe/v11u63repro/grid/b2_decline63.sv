// v11u63 BREAKER GRID b2 — the DANGEROUS face: roots where GOLDEN DECLINES the
// typespec edge but our parentNets holds an expr that HAS one.  Any cell where
// golden says ts=<none> and the law says ts=<something> is pristine-RIGHT ->
// patched-WRONG.
package qk63;
  typedef struct packed { logic [31:0] a; logic [31:0] b; } st_t;
  st_t pgv;
endpackage

module sink (input logic [31:0] a_i, output logic [31:0] o); assign o = a_i; endmodule

interface ifq;
  qk63::st_t v;
  modport mp (input v);
endinterface

// c01 — root is an INTERFACE PORT of the holder (plain, no modport)
module c01 (ifq p, output logic [31:0] o); sink u (.a_i(p.v.a), .o(o)); endmodule

// c02 — root is a MODPORT-qualified interface port
module c02 (ifq.mp p, output logic [31:0] o); sink u (.a_i(p.v.a), .o(o)); endmodule

// c03 — root is an INTERFACE-ARRAY port element
module c03 (ifq p [0:1], output logic [31:0] o); sink u (.a_i(p[0].v.a), .o(o)); endmodule

// c04 — root declared in an UNNAMED generate block
module c04 (output logic [31:0] o);
  if (1) begin
    qk63::st_t uv;
    sink u (.a_i(uv.a), .o(o));
  end
endmodule

// c05 — root imported by WILDCARD from a package (unqualified `pgv.a`)
module c05 (output logic [31:0] o);
  import qk63::*;
  sink u (.a_i(pgv.a), .o(o));
endmodule

// c06 — root is a struct declared in a generate CASE block
module c06 #(parameter int P = 1) (output logic [31:0] o);
  case (P)
    1: begin : cb
      qk63::st_t cv;
      sink u (.a_i(cv.a), .o(o));
    end
    default: begin : cb2 assign o = 32'd0; end
  endcase
endmodule

// c07 — root is a struct LOCALPARAM (golden FOLDS: residue R2 face)
module c07 (output logic [31:0] o);
  localparam qk63::st_t LPV = '{a: 32'd1, b: 32'd2};
  sink u (.a_i(LPV.a), .o(o));
endmodule

// c08 — root is a PARAMETER (not localparam) of struct type
module c08 #(parameter qk63::st_t PV = '{a: 32'd3, b: 32'd4}) (output logic [31:0] o);
  sink u (.a_i(PV.a), .o(o));
endmodule

// c09 — the connection lives in a module reached only through a BIND
module c09target (output logic [31:0] o); assign o = 32'd0; endmodule
module c09bound (output logic [31:0] o); qk63::st_t bv; sink u (.a_i(bv.a), .o(o)); endmodule

// c10 — root is a struct declared in the TOP module, connection at top level
module c10 (output logic [31:0] o); qk63::st_t tv; sink u (.a_i(tv.a), .o(o)); endmodule

// c11 — a NAMED connection whose actual is a member of a struct that is ALSO
//       the whole actual of a second, POSITIONAL connection on the same module
module sink2 (input logic [31:0] a_i, input logic [31:0] b_i, output logic [31:0] o);
  assign o = a_i ^ b_i; endmodule
module c11 (output logic [31:0] o);
  qk63::st_t mv;
  sink2 u (.a_i(mv.a), .b_i(mv.b), .o(o));
endmodule

// c12 — root is a struct net driven by a cont_assign, connection is NAMED but
//       the formal is an OUTPUT (the actual is the LHS side)
module srcm (output logic [31:0] q_o); assign q_o = 32'd9; endmodule
module c12 (output logic [31:0] o); qk63::st_t ov; srcm u (.q_o(ov.a)); assign o = ov.b; endmodule

module tb;
  logic [31:0] o01,o02,o03,o04,o05,o06,o07,o08,o09,o10,o11,o12;
  ifq bus(); ifq busa [0:1] ();
  c01 i01 (.p(bus), .o(o01));
  c02 i02 (.p(bus), .o(o02));
  c03 i03 (.p(busa), .o(o03));
  c04 i04 (.o(o04));
  c05 i05 (.o(o05));
  c06 #(.P(1)) i06 (.o(o06));
  c07 i07 (.o(o07));
  c08 i08 (.o(o08));
  c09target i09 (.o(o09));
  c10 i10 (.o(o10));
  c11 i11 (.o(o11));
  c12 i12 (.o(o12));
endmodule

bind c09target c09bound bnd (.o());
