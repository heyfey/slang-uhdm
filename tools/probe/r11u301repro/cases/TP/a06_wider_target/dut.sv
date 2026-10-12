// § caTernParamArmReusesPaConst301
module dut #(parameter bit EN = 1) (output logic [7:0] y);
  localparam logic [3:0] XV = 4'bx1x1;
  assign y = EN ? XV : 8'h0;
endmodule
