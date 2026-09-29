// § ifArrElemLitCaFresh225 — two-dimensional interface array
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(output logic o);
  localparam int K = 1;
  bi b[2][2]();
  assign b[1][K].w = 1'b1;
  assign o = b[0][0].w;
endmodule
