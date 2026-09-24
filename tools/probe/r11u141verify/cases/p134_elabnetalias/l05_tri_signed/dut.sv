// § elabNetTdCloneNoAlias134
// case l05: a tri net typed by a module-local signed vector typedef
module top(output logic [3:0] o);
  typedef logic signed [3:0] s_t;
  tri s_t w;
  assign w = -4'sd2;
  assign o = w;
endmodule
