// § ifArrElemLitCaFresh225 (a parenthesised literal)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic o);
  bi b[2]();
  assign b[1].w = (1'b1);
  assign o = b[1].w;
endmodule
