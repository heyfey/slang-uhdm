// § caTernParamArmReusesPaConst301
typedef logic [3:0] n_t;
module dut #(parameter bit EN = 1) (output n_t y);
  localparam n_t XV = 4'bz1z1;
  assign y = EN ? XV : 4'h0;
endmodule
