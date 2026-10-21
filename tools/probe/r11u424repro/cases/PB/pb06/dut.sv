// § defGenLpSysArgBitSelAtIndex424 (r11u421 PB/pb06)
module top #(parameter bit [3:0][3:0] P = 0) (output logic [3:0] o);
  genvar i;
  for (i = 0; i < 3; i=i+1) begin: rof
    localparam W = $countones(P[i]);
    assign o[i] = W > 1;
  end
endmodule
