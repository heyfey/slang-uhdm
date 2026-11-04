// § sysCallArgRefScopedName303
module sub #(parameter int W = 1) (output logic [7:0] o); assign o = W; endmodule
module dut #(parameter int N = 8) (output logic [7:0] o [2]);
  for (genvar k = 0; k < 2; k++) begin : g
    sub #(.W($clog2(N))) u (.o(o[k]));
  end
endmodule
