// § caTernParamArmReusesPaConst301
module dut #(parameter int W = 3) (output logic [3:0] y);
  localparam logic [3:0] XV = 4'bx1x1;
  assign y = (W > 2) ? XV : 4'h0;
endmodule
