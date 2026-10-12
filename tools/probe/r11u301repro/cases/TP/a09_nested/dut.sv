// § caTernParamArmReusesPaConst301
module dut #(parameter int S = 1) (output logic [3:0] y);
  localparam logic [3:0] XV = 4'bx1x1;
  assign y = (S == 0) ? 4'h1 : (S == 1) ? XV : 4'h2;
endmodule
