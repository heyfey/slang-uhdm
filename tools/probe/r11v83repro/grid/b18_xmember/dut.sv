// v11v83 b18 -- LAW B's DECLINE path: a struct-parameter member whose value
// carries X.  `caStructParamSetter55` answers a setter, so the clone is
// FORCED; if `emitCaStructParamSubst55` then declines, the elaborated cell is
// a fresh clone with an unbound Lhs where pristine shared the def object.
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
endpackage

interface ifc #(parameter pk::s_t C = '{n: 8'bxxxx_xxxx, m: 8'd9}) ();
  logic [31:0] x_un;
  logic [31:0] x_ok;
  assign x_un = C.n;
  assign x_ok = C.m;
endinterface

module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.x_un ^ u_if.x_ok;
endmodule
