// § paramInitSysArgBitSelAtIndex421
module top #(parameter bit [3:0][3:0] P = 0) (output logic [3:0] o);
  for (genvar i = 0; i < 3; i++) begin : g
    localparam W = $clog2(P[i]);
    assign o[i] = W > 1;
  end
endmodule
