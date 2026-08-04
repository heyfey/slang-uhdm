module nm #(
  parameter logic [7:0]  NB3 = 'b101,
  parameter logic [7:0]  NB0 = 'b0,
  parameter int          NBI = 'b1,
  parameter logic [7:0]  NO2 = 'o10,
  parameter logic [7:0]  NHU = 'hFF,
  parameter bit [3:0]    NH4 = 'h1,
  parameter logic [7:0]  ND3 = 'd300,
  parameter logic [7:0]  NSH = 'sh1f,
  parameter logic [7:0]  NSB = 'sb11,
  parameter logic        NB1 = 'b1,
  parameter logic [63:0] NHL = 'hdeadbeef
) (
  input clk_i
);
endmodule
