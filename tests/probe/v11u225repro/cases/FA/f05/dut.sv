// § ifArrElemLitCaFresh225 — fresh: the target module instantiated under a generate loop (a deep elaborated prefix)
interface bi;
  logic w;
endinterface
module m(output logic o);
  localparam int K = 1;
  bi b[2]();
  assign b[K].w = 1'b1;
  assign o = b[K].w;
endmodule
module dut(output logic [1:0] o);
  for (genvar g = 0; g < 2; g++) begin : G
    m u(.o(o[g]));
  end
endmodule
