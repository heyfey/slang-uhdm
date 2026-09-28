// § elabIfArrIdxChainName205 — r11u217 a04: an interface-array PORT of a child module driven in the child's for-generate with literal right sides, the child instantiated twice with different array sizes (parameter), and a PARAMETER index target `b[P].w` (v11u210 F2)
interface bi;
  logic w;
endinterface
module ch #(parameter int N = 2, parameter int P = 0) (bi b [N]);
  for (genvar i = 1; i < N; i++) begin : g
    assign b[i].w = 1'b1;
  end
  if (N > 0) begin : gp
    assign b[P].w = 1'b0;
  end
endmodule
module dut(output logic o, output logic p);
  bi x[2]();
  bi y[3]();
  ch #(.N(2)) c0 (.b(x));
  ch #(.N(3)) c1 (.b(y));
  assign o = x[1].w;
  assign p = y[2].w;
endmodule
