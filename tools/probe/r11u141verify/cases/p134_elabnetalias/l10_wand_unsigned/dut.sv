// § elabNetTdCloneNoAlias134
// case l10_wand_unsigned: a wand net typed by a module-local vector typedef (logic [3:0])
module top(output logic [3:0] o);
  typedef logic [3:0] t_t;
  wand t_t w;
  assign w = 4'd3;
  assign o = w;
endmodule
