// § sizeBitNetIsVar228 § parseViewSizeExprEval228 — a typedef'd bit net port
typedef bit [3:0][1:0] bp_t;
module sub (input bp_t pp, output logic [7:0] o1);
  wire [7:0] w1 = $size(pp);
  assign o1 = w1;
endmodule
module dut (input bp_t i, output logic [7:0] o1);
  sub u (.pp(i), .o1(o1));
endmodule
