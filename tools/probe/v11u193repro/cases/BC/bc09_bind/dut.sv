// § castOperandLeafElab193
module chk (input [6:0] d);
  logic [6:0] q;
  assign q = d;
endmodule
module dut (input logic [3:0] a, output logic [3:0] o);
  logic [3:0] r;
  assign r = a;
  assign o = r;
endmodule
bind dut chk u_chk (.d(7'(r)));
