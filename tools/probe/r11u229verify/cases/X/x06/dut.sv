// § hpLvSelIdxNamesByPath224 § ifArrElemLitCaFresh225 (both laws in one module: an interface-array literal target and an lvalue path select)
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module top(input int i, input logic [1:0] d, output logic o);
  typedef struct { logic [3:0] arr [4]; } s_t;
  localparam int K = 1;
  s_t s;
  bi b[2]();
  assign b[K].w = 1'b1;
  always_comb s.arr[i][1:0] = d;
  assign o = b[K].w;
endmodule
