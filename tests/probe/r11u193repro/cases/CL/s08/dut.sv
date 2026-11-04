// § castOperandLeafElab193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [3:0] i, output logic [7:0] o);
  logic [3:0] r;
  assign r = i;
  for (genvar g = 0; g < 2; g++) begin : gl
    logic [7:0] oo;
    sub u (.d(7'(r)), .o(oo));
  end
  assign o = gl[0].oo;
endmodule
