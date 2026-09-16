// ROAD A control: the SAME type-parameter argument in an INTERFACE body, and
// the package-typedef control beside it.
package pk;
  typedef struct packed { logic [31:0] a; logic [63:0] d; logic w; } req_t;
endpackage
interface ifc #(parameter type TP = pk::req_t) ();
  localparam int IW1 = $bits(TP);
  localparam int IW2 = $bits(pk::req_t);
  logic [IW1-1:0] x;
  logic [IW2-1:0] y;
endinterface
module dut (output logic o);
  ifc u();
  assign o = ^{u.x[0], u.y[0]};
endmodule
