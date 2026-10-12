// § caTernParamArmReusesPaConst301
module dut #(parameter bit EN = 1) (output logic [3:0] y);
  localparam logic [3:0] ZV = 4'bzz01;
  assign y = EN ? ZV : 4'h0;
endmodule
