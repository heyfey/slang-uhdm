// § modTdElabFoldSize249
module sub(input logic [3:0] a, output logic [3:0] o);
  typedef logic [3:0] f_t[3];
  f_t x;
  assign x[2] = a;
  assign o = x[2];
endmodule
module top(input logic [3:0] a, output logic [3:0] o1, o2);
  sub u1(a, o1);
  sub u2(~a, o2);
endmodule
