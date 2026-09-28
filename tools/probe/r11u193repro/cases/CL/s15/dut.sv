// § castOperandLeafElab193
module sub #(parameter W = 7) (input [W-1:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [3:0] i, output logic [7:0] o);
  logic [3:0] r;
  assign r = i;
  sub #(.W(5)) u (.d(5'(r)), .o(o));
endmodule
