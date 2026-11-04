// § modTdElabFoldSize249 (control: the law does not fire)
module top(input logic [7:0] i, output logic [7:0] o);
  typedef logic [7:0] f_t[2];
  f_t x;
  assign x[0] = i;
  assign x[1] = x[0];
  assign o = x[1];
endmodule
