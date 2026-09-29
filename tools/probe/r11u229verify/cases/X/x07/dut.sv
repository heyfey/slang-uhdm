// § hpLvSelIdxNamesByPath224 § ifArrElemLitCaFresh225 (an lvalue path select through an interface-array element, beside a literal target of the same element)
interface bi;
  typedef struct { logic [3:0] arr [4]; } s_t;
  logic w;
  s_t s;
endinterface
module top(input int i, input logic [1:0] d, output logic o);
  localparam int K = 1;
  bi b[2]();
  assign b[K].w = 1'b1;
  always_comb b[K].s.arr[i][1:0] = d;
  assign o = b[K].w;
endmodule
