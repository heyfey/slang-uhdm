// § ifArrElemLitCaFresh225 (an interface array declared [3:0], a descending range)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic o);
  bi b[3:0]();
  assign b[0].w = 1'b0;
  assign o = b[0].w;
endmodule
