// § caTernParamArmReusesPaConst301
module dut #(parameter bit EN = 1) (output logic [3:0] y);
  localparam logic [3:0] KV = 4'b1010;
  assign y = EN ? KV : 4'h0;
endmodule
