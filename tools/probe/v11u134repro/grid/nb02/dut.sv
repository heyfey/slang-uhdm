// § elabNetTdCloneNoAlias134
module top(input logic [3:0] i, output logic [3:0] o);
  typedef logic signed [3:0] sv_t;
  typedef logic [3:0] bv_t;
  tri sv_t t1;
  wire bv_t t2;
  sv_t t3;
  assign t1 = i;
  assign t2 = i;
  assign t3 = i;
  assign o = t1 ^ t2 ^ t3;
endmodule
