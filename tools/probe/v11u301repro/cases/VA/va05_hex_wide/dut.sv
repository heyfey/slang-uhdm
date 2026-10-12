// § caTernParamArmReusesPaConst301
module dut #(parameter bit EN = 1) (output logic [7:0] y);
  localparam logic [7:0] XV = 8'hx3;
  assign y = EN ? XV : 8'h0;
endmodule
