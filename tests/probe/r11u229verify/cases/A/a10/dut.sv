// § ifArrElemLitCaFresh225 (a literal and a signal-reading assignment to two members of one element)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(input logic [3:0] x, output logic o, output logic [3:0] p);
  bi b[2]();
  assign b[0].w = 1'b1;
  assign b[0].v = x;
  assign o = b[0].w;
  assign p = b[0].v;
endmodule
