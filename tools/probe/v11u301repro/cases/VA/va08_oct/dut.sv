// § ternParamArmLeadXzOnly301v
module dut #(parameter bit EN = 1) (output logic [5:0] y);
  localparam logic [5:0] XV = 6'o7x;
  assign y = EN ? XV : 6'o0;
endmodule
