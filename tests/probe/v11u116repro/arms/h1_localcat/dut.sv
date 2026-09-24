module dut (input logic [31:0] x, output logic [31:0] z);
  localparam logic [31:0] L_CAT = { 16'h1, 16'h73 };
  parameter logic [31:0] M_CAT = { 16'h2, 16'h73 };
  assign z = x & L_CAT & M_CAT;
endmodule
