// § insideSetParamFoldKeepsPa270
module top #(parameter int P = 2) (input int w, output logic [3:0] o);
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : h
      localparam int L = i * 2 + j;
      always_comb o[L] = w inside {L, P};
    end
  end
endmodule
