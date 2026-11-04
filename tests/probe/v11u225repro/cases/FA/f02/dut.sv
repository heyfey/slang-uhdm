// § ifArrElemLitCaFresh225 — fresh: unbased fills '0, 'x and 'z onto interface-array element members
interface bi;
  logic w;
  logic [3:0] v;
  logic [3:0] z;
endinterface
module dut(output logic [3:0] o, output logic p);
  localparam int K = 1;
  bi b[2]();
  assign b[K].w = '0;
  assign b[K].v = 'x;
  assign b[0].z = 'z;
  assign o = b[K].v | b[0].z;
  assign p = b[K].w;
endmodule
