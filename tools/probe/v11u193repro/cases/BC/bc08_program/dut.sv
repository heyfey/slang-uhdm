// § castOperandLeafElab193
program pr (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endprogram
module dut (input logic [3:0] a, output logic [7:0] o);
  logic [3:0] r;
  assign r = a;
  pr u (.d(7'(r)), .o(o));
endmodule
