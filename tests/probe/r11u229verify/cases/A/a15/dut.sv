// § ifArrElemLitCaFresh225 (x and z digits through a localparam selector)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic [3:0] o);
  localparam int K = 1;
  bi b[2]();
  assign b[K].v = 4'bx1z0;
  assign o = b[K].v;
endmodule
