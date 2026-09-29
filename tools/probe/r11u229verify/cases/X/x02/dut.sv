// § hpLvSelIdxNamesByPath224 § ifArrElemLitCaFresh225 (an interface-array element whose index is a path)
interface bi;
  logic w;
  logic [3:0] v;
  logic [15:0] h;
endinterface
module top(output logic o, output logic [3:0] p);
  typedef struct packed { int k; } s_t;
  localparam s_t S = s_t'(1);
  bi b[2]();
  assign b[S.k].w = 1'b1;
  always_comb b[S.k].v[1:0] = 2'b01;
  assign o = b[1].w;
  assign p = b[1].v;
endmodule
