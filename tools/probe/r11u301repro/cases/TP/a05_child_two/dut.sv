// § caTernParamArmReusesPaConst301
module c #(parameter bit EN = 1, parameter logic [3:0] XV = 4'bx1x1) (output logic [3:0] y);
  assign y = EN ? XV : 4'h0;
endmodule
module dut (output logic [3:0] y, z);
  c u0 (.y(y));
  c #(.XV(4'b1x1x)) u1 (.y(z));
endmodule
