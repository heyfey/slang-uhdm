// § elabNetTdCloneNoAlias134
// case l09_wire_signed: a wire net typed by a module-local vector typedef (logic signed [3:0])
module top(output logic [3:0] o);
  typedef logic signed [3:0] t_t;
  wire t_t w;
  assign w = -4'sd2;
  assign o = w;
endmodule
