// § ifaceConnLeftmostLeafElab315
interface ifc (input logic clk);
  logic [7:0] sig;
endinterface
typedef struct packed { logic x; logic y; } st_t;
module top (input st_t s, input logic b, output logic o);
  ifc u (.clk(b & s.x));
  assign o = u.sig[0];
endmodule
