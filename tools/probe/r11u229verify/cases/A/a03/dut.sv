// § ifArrElemLitCaFresh225 (based literals holding x and z digits)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic [3:0] o);
  bi b[2]();
  assign b[0].v = 4'bx1z0;
  assign b[1].v = 4'hz;
  assign o = b[0].v ^ b[1].v;
endmodule
