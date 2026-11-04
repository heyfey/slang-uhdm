// § strLitContOwnerEnd224 § ifArrElemLitCaFresh225 (a conditional ending at a continued literal onto an interface-array element: the owner law, and the element law declining a non-literal right side)
interface bi;
  logic w;
  logic [15:0] h;
endinterface
module top(input logic c, output logic [15:0] o);
  bi b[2]();
  assign b[1].h = c ? 16'h0 : "ab \
c";
  assign b[0].w = 1'b1;
  assign o = b[1].h;
endmodule
