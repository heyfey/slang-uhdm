// § parseViewSizeExprEval228 § sizeBitNetIsVar228 — ANSI bit ports (input and output) and a non-ANSI bit port
module sub (pn, o3);
  input bit [2:0][3:0] pn;
  output logic [7:0] o3;
  wire [7:0] w3 = $size(pn);
  assign o3 = w3;
endmodule
module dut (input bit [3:0][1:0] pp, input bit [4:0] p1, output logic [7:0] o1, o2, o3);
  wire [7:0] w1 = $size(pp);
  wire [7:0] w2 = $size(p1);
  sub u (.pn('0), .o3(o3));
  assign o1 = w1; assign o2 = w2;
endmodule
