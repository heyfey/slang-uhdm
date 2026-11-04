// § boundLitWrittenDigits172
module sub #(parameter int W = 8) (input logic [W-1:00] a, output logic [07:0] o);
  assign o = a[7:0];
endmodule
module dut (input logic [15:00] a, output logic [07:0] o, p);
  sub #(.W(16)) u1(a, o);
  sub u2(a[07:0], p);
endmodule
