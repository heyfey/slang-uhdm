package pk; parameter int unsigned P = 5; endpackage
module c import pk::*; (input wire [P:0] i, output var logic [P:0] o);
  assign o = i;
endmodule
module top (input logic [7:0] i, output logic [7:0] o);
  c u (.i(i[5:0]), .o(o[5:0]));
  assign o[7:6] = '0;
endmodule
