// § castOperandLeafElab193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [3:0] i, output logic [7:0] o);
  logic [3:0] r;
  logic [1:0] k;
  assign r = i;
  assign k = i[1:0];
  sub u (.d(7'(r[k])), .o(o));
endmodule
