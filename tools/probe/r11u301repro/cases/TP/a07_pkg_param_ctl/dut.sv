// § caTernParamArmReusesPaConst301
package pk;
  localparam logic [3:0] XV = 4'bx1x1;
endpackage
module dut #(parameter bit EN = 1) (output logic [3:0] y);
  assign y = EN ? pk::XV : 4'h0;
endmodule
