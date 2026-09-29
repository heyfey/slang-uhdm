// § ifArrElemLitCaFresh225 — an interface holding the interface array
interface bi;
  logic w;
endinterface
interface outer;
  localparam int K = 1;
  bi b[2]();
  assign b[K].w = 1'b1;
endinterface
module dut(output logic o);
  outer u();
  assign o = u.b[1].w;
endmodule
