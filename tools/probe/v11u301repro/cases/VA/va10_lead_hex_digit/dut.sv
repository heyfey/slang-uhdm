// § ternParamArmLeadXzOnly301v
module dut #(parameter bit EN = 1) (output logic [7:0] y);
  localparam logic [7:0] XV = 8'h3x;
  assign y = EN ? XV : 8'h0;
endmodule
