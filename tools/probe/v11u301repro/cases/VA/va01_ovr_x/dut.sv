// § caTernParamArmReusesPaConst301
module child #(parameter bit EN = 1, parameter logic [3:0] XV = 4'bx1x1) (output logic [3:0] y);
  assign y = EN ? XV : 4'h0;
endmodule
module dut (output logic [3:0] y);
  child #(.XV(4'b1x0x)) u (.y(y));
endmodule
