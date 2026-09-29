// § ifArrElemLitCaFresh225 (a part select of the member: another branch)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic [3:0] o);
  bi b[2]();
  assign b[1].v[1:0] = 2'b10;
  assign o = b[1].v;
endmodule
