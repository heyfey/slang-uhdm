// § ifArrElemLitCaFresh225 (an enum selector into an array declared [3:0])
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic o);
  typedef enum logic [1:0] { E0, E1, E2 } e_t;
  bi b[3:0]();
  assign b[E2].w = 1'b0;
  assign o = b[E2].w;
endmodule
