// § ifArrElemLitCaFresh225 (a drive strength on the continuous assignment)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic o);
  bi b[2]();
  assign (strong0, weak1) b[1].w = 1'b1;
  assign o = b[1].w;
endmodule
