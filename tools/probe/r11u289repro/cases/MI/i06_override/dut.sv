// § caStructParamIfaceCloneReused289
package pk;
  typedef struct packed { logic [3:0] n; logic [7:0] m; } s_t;
endpackage
interface ifc #(parameter pk::s_t C = '{n: 4'h6, m: 8'h12}) ();
  logic [7:0] e;
  assign e = C.m;
endinterface
module dut (output logic [7:0] p);
  ifc #(.C('{n: 4'h1, m: 8'h34})) u_a ();
  assign p = u_a.e;
endmodule
