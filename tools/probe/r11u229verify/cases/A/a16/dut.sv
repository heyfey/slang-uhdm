// § ifArrElemLitCaFresh225 (a drive strength, a localparam selector)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic o);
  localparam int K = 1;
  bi b[2]();
  assign (strong0, weak1) b[K].w = 1'b1;
  assign o = b[K].w;
endmodule
