// § elabIfArrIdxChainName205 — i05: an interface-array port driven in a child instantiated twice (depth 2), literal right side, and an always_comb target beside it
interface bi;
  logic w;
  logic z;
  modport m (output w, output z);
endinterface
module drv (bi.m p [2]);
  for (genvar i = 0; i < 2; i++) begin : g
    assign p[i].w = 1'b0;
  end
  always_comb p[0].z = 1'b1;
  always_comb p[1].z = 1'b0;
endmodule
module mid (output logic o);
  bi b[2]();
  drv u (.p(b));
  assign o = b[1].w | b[0].z;
endmodule
module dut(output logic o1, output logic o2);
  mid m1 (.o(o1));
  mid m2 (.o(o2));
endmodule
