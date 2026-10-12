// § ternParamArmLeadXzOnly301v
module dut #(parameter bit EN = 1) (output logic [3:0] y);
  localparam logic [3:0] XV = 4'b0x1x;
  assign y = EN ? XV : 4'h0;
endmodule
