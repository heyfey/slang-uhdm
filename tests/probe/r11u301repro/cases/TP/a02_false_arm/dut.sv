// § caTernParamArmReusesPaConst301
module dut #(parameter bit EN = 0) (output logic [3:0] y);
  localparam logic [3:0] XV = 4'bx1x1;
  assign y = EN ? 4'h0 : XV;
endmodule
