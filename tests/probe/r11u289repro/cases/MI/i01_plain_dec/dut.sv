// § caStructParamIfaceCloneReused289
package pk;
  typedef struct packed { logic [7:0] n; logic [7:0] m; } s_t;
endpackage
interface ifc #(parameter pk::s_t C = '{n: 8'd6, m: 8'd9}) ();
  logic [31:0] d;
  assign d = C.n;
endinterface
module dut (output logic [31:0] o);
  ifc u_if ();
  assign o = u_if.d;
endmodule
