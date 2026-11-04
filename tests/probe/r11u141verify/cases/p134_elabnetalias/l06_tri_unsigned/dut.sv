// § elabNetTdCloneNoAlias134
// case l06_tri_unsigned: a tri net typed by a module-local vector typedef (logic [3:0])
module top(output logic [3:0] o);
  typedef logic [3:0] t_t;
  tri t_t w;
  assign w = 4'd2;
  assign o = w;
endmodule
