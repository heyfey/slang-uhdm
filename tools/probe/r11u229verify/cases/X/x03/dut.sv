// § strLitPpEscIdShift224 § ifArrElemLitCaFresh225 (a backtick literal then an interface-array literal target on one line)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic [15:0] o, output logic q);
  bi b[2]();
  assign b[0].h = "a\nb` c"; assign b[1].w = 1'b1;
  assign o = b[0].h;
  assign q = b[1].w;
endmodule
