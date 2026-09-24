package mask_pkg;
  localparam logic [1:0][1:0][3:0] PA = 16'h1234;
endpackage
module sub (input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule
module top (output logic [3:0] o);
  sub u (.i(mask_pkg::PA[1][0]), .o(o));
endmodule
