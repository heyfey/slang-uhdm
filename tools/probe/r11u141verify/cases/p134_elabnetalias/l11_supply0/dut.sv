// § elabNetTdCloneNoAlias134
// case l11_supply0: a supply0 net typed by a module-local vector typedef (logic [3:0])
module top(output logic [3:0] o);
  typedef logic [3:0] t_t;
  supply0 t_t w;
  
  assign o = w;
endmodule
