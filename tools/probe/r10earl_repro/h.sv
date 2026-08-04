package hp;
  parameter logic [7:0] PH = 'h0;
  parameter logic [7:0] PB = 'b1;
  parameter logic [7:0] PD = 'd5;
  parameter logic [7:0] PO = 'o7;
  parameter             PU = 'h3;
endpackage

module hm #(
  parameter logic [7:0]  MH = 'h0,
  parameter logic [7:0]  MB = 'b1,
  parameter logic [7:0]  MD = 'd5,
  parameter logic [7:0]  MO = 'o7,
  parameter              MU = 'h3,
  parameter int          MI = 'h9,
  parameter logic [15:0] MW = 'hab
) (
  input clk_i
);
endmodule
