package pk;
  parameter logic [7:0] P_CAT [2] = '{ {4'h1, 4'h2}, 8'h3 };
  parameter logic [15:0] P_ST = {8'h1, 8'h2};
endpackage
module dut import pk::*; (input logic [7:0] x, output logic [7:0] z, output logic [15:0] z2);
  assign z = x & P_CAT[0];
  assign z2 = {x, x} ^ P_ST;
endmodule
