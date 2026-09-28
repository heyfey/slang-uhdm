// § castOperandLeafElab193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [3:0] a [2], output logic [7:0] o [2]);
  logic [3:0] r [2];
  assign r = a;
  for (genvar i = 0; i < 2; i++) begin : g
    sub u (.d(7'(r[i])), .o(o[i]));
  end
endmodule
