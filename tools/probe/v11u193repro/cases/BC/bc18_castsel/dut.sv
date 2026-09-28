// § castOperandLeafElab193
module sub (input [6:0] d, output logic [7:0] o);
  assign o = 8'(d);
endmodule
module dut (input logic [7:0] a, input logic [1:0] s, output logic [7:0] o);
  logic [7:0] r;
  logic [1:0] rs;
  assign r = a;
  assign rs = s;
  sub u (.d(7'(r[rs])), .o(o));
endmodule
