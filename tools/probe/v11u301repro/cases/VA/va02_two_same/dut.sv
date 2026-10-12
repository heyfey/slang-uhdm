// § caTernParamArmReusesPaConst301
module child #(parameter bit EN = 1) (output logic [3:0] y);
  localparam logic [3:0] XV = 4'bx1x1;
  assign y = EN ? XV : 4'h0;
endmodule
module dut (output logic [7:0] y);
  child u0 (.y(y[3:0]));
  child u1 (.y(y[7:4]));
endmodule
