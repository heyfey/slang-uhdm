// § ifArrElemLitCaFresh225 (a string literal through a localparam expression selector)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic [15:0] o);
  localparam int K = 2;
  bi b[2]();
  assign b[K-1].h = "AB";
  assign o = b[K-1].h;
endmodule
