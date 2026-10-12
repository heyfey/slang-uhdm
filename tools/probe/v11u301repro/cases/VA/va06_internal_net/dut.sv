// § ternParamArmLeadXzOnly301v
module dut #(parameter bit EN = 0) (output logic [3:0] o);
  localparam logic [3:0] XV = 4'b10xx;
  wire [3:0] y;
  assign y = EN ? 4'h1 : XV;
  assign o = y;
endmodule
