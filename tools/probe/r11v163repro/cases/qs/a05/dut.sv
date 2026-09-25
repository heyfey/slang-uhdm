// § aggParamFoldQualSpanByView163
package pkg;
  typedef struct packed { logic [7:0] a; logic [7:0] b; } s_t;
  localparam s_t XLONG = 16'h1234;
endpackage
interface ifc #(parameter pkg::s_t P = pkg::XLONG) ();
  logic [7:0] q;
  assign q = P.a;
endinterface
module top(); ifc i(); endmodule
