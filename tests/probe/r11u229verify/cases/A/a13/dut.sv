// § ifArrElemLitCaFresh225 (a localparam selector into an array declared [1:4])
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic o);
  localparam int K = 2;
  bi b[1:4]();
  assign b[K].w = 1'b1;
  assign o = b[K].w;
endmodule
