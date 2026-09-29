// § ifArrElemLitCaFresh225 — interface array port, modport-qualified
interface bi;
  logic w;
  modport mp(output w);
endinterface
module sub(bi.mp pb[2]);
  localparam int K = 1;
  assign pb[K].w = 1'b1;
  assign pb[0].w = 1'b0;
endmodule
module dut(output logic o);
  bi b[2]();
  sub s(.pb(b));
  assign o = b[1].w;
endmodule
