// § ifArrElemLitCaFresh225 — fresh: a typedef enum selector and a parameter-expression selector, an interface with a modport
interface bi;
  logic w;
  logic [1:0] v;
  modport mp(input w, input v);
endinterface
module dut(output logic o, output logic [1:0] q);
  typedef enum logic [1:0] {A, B, C} e_t;
  localparam int K = 1;
  bi b[3]();
  assign b[B].w = 1'b1;
  assign b[K+1].v = 2'b10;
  assign o = b[B].w;
  assign q = b[K+1].v;
endmodule
