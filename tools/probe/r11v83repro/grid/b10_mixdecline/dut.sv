// v11u83 b10 -- LAW B BREAK: folding and NON-folding cells interleaved in one
// interface body.  A declined cell must keep the pristine SHARED def object;
// a taken one must fold its OWN member.  Cells: literal, struct member,
// signal read, struct member, select-Lhs struct member.
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
endpackage

interface ifc #(parameter pk::s_t C = '{n: 8'd7, m: 8'd13}) ();
  logic [31:0] lit;
  logic [31:0] f1;
  logic [31:0] sigrd;
  logic [31:0] f2;
  logic [31:0] selv;
  logic [31:0] src;
  assign lit   = 32'd99;
  assign f1    = C.n;
  assign sigrd = src;
  assign f2    = C.m;
  assign selv[3:0] = C.n;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.lit ^ u_if.f1 ^ u_if.sigrd ^ u_if.f2 ^ u_if.selv;
endmodule
