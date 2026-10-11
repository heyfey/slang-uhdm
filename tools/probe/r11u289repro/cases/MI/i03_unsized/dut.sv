// § caStructParamIfaceCloneReused289
package pk;
  typedef struct packed { int unsigned n; } cfg_t;
  localparam cfg_t LIT = '{n: 6};
endpackage
interface ifc #(parameter pk::cfg_t C = pk::LIT) ();
  logic [31:0] whole;
  assign whole = C.n;
endinterface
module dut (output logic [31:0] o);
  ifc u_i ();
  assign o = u_i.whole;
endmodule
