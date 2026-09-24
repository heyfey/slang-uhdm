// § elabNetTdCloneNoAlias134
// case l04: a net typed by a module-local vector typedef in a sub-module, driven from a port
module sub(input logic [3:0] i, output logic [3:0] o);
  typedef logic [3:0] n_t;
  wire n_t w;
  assign w = i;
  assign o = w;
endmodule
module top(input logic [3:0] i, output logic [3:0] o);
  sub u(.i(i), .o(o));
endmodule
