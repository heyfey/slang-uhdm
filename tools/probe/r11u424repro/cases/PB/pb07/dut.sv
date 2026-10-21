// § defGenLpSysArgBitSelAtIndex424
module top #(parameter bit [3:0][3:0] P = 0) (output logic [3:0] o);
  genvar i;
  for (i = 0; i < 2; i=i+1) begin: rof
    localparam W = $bits(P[i+1]);
    localparam V = $clog2(P[1]) + 1;
    assign o[i] = W > V;
  end
endmodule
