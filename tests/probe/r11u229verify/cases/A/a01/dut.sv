// § ifArrElemLitCaFresh225 (an interface array declared [1:4])
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic o);
  bi b[1:4]();
  assign b[2].w = 1'b1;
  assign o = b[2].w;
endmodule
