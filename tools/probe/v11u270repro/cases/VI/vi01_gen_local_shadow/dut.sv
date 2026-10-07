// § insideSetParamFoldKeepsPa270
module top #(parameter int P = 1) (input int w, output logic o);
  localparam int Q = 3;
  if (1) begin : g
    localparam int P = 5;
    always_comb o = w inside {P, Q};
  end
endmodule
