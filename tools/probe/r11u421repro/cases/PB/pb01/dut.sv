// § paramInitSysArgBitSelAtIndex421
`define CNT(y) ((($bits(y) < 65) ? 1'b0 : 1'b1) + 1)
module top #(parameter bit [3:0][3:0] P = 0) (output logic [3:0] o);
  genvar i;
  for (i = 0; i < 3; i=i+1) begin: rof
    localparam W = `CNT(P[i]);
    assign o[i] = W > 1;
  end
endmodule
