package pk;
  parameter logic [31:0] P_CAT = { 16'h0, 16'h73 };
  parameter logic [31:0] P_REP = { {25{1'b0}}, 7'h37 };
endpackage
module dut import pk::*; (input logic [31:0] x, output logic [31:0] z);
  task automatic t(output logic [31:0] o); o = P_CAT; endtask
  always_comb t(z);
endmodule
