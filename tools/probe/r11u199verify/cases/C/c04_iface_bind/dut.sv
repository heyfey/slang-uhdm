// § castOperandLeafElab193 § connCastTsNamedByPort193
interface ifc (input [6:0] d);
  logic [6:0] q;
  assign q = d;
endinterface
module chk (input [6:0] d, output logic ok);
  assign ok = |d;
endmodule
module dut (input logic [9:0] i, output logic [6:0] o, output logic ok);
  logic [9:0] r;
  assign r = i;
  ifc u_if (.d(7'(r)));
  assign o = u_if.q;
endmodule
bind dut chk u_chk (.d(7'(r)), .ok(ok));
