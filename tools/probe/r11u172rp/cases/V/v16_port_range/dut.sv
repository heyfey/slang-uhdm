module sub (input logic [07:00] i, output logic [07:00] o);
  assign o = i;
endmodule
module top (input logic [7:0] i, output logic [7:0] o);
  sub u (.i(i), .o(o));
endmodule
