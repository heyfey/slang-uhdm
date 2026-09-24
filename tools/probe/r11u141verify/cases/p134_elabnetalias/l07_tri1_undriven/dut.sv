// § elabNetTdCloneNoAlias134
// case l07_tri1_undriven: a tri1 net typed by a module-local vector typedef (logic [3:0])
module top(output logic [3:0] o);
  typedef logic [3:0] t_t;
  tri1 t_t w;
  
  assign o = w;
endmodule
