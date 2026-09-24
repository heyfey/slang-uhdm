package mask_pkg;
  localparam logic [1:0][7:0] ARR = 16'hA55A;
endpackage
module sub (input logic [3:0] i, output logic [3:0] o);
  assign o = i;
endmodule
module top (output logic [3:0] o);
  sub u (.i(mask_pkg::ARR[1][3:0]), .o(o));
endmodule
