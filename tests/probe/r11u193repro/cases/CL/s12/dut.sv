// § castOperandLeafElab193
interface ifc (input logic [6:0] d);
  logic [6:0] q;
  assign q = d;
endinterface
module dut (input logic [3:0] i, output logic [6:0] o);
  logic [3:0] r;
  assign r = i;
  ifc u (.d(7'(r)));
  assign o = u.q;
endmodule
