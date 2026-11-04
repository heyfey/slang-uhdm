package pkg;
  localparam int W = 4;
  typedef logic [W-1:0] w_t;
endpackage
module top(output logic [3:0] o);
  pkg::w_t a = '1;
  assign o = a;
endmodule
