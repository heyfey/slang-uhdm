// § caTernParamArmReusesPaConst301
module dut #(parameter EN = 1) (output logic [3:0] y);
  localparam [3:0] XV = 4'bx1x1;
  assign y = EN ? XV : 4'h0;
endmodule
