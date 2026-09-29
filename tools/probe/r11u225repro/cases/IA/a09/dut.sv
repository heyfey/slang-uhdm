// § ifArrElemLitCaFresh225 — numeric index
interface bi;
  logic w;
  logic [3:0] v;
endinterface
module dut(output logic o);
  bi b[2]();
  assign b[1].w = 1'b1;
  assign o = b[0].w;
endmodule
