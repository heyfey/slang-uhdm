// § elabNetTdCloneNoAlias134
// case l08_wor_unsigned: a wor net typed by a module-local vector typedef (logic [3:0])
module top(output logic [3:0] o);
  typedef logic [3:0] t_t;
  wor t_t w;
  assign w = 4'd6;
  assign o = w;
endmodule
