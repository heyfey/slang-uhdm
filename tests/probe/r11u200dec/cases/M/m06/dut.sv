module sub (input logic [1:0] [3:0] b, output logic [1:0] [3:0] d);
  assign d = b;
endmodule
module m06 (input logic [1:0][3:0] b, output logic [1:0][3:0] d);
  sub u (.b(b), .d(d));
endmodule
