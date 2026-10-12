// § caTernParamArmReusesPaConst301
module dut #(parameter bit EN = 0) (output logic [3:0] y);
  localparam logic [3:0] XV = 4'bz100;
  assign y = EN ? 4'h1 : XV;
endmodule
