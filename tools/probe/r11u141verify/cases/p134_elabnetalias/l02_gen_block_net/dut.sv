// § elabNetTdCloneNoAlias134
// case l02: a net typed by a module-local vector typedef inside a generate block
module top(output logic [3:0] o);
  typedef logic [3:0] n_t;
  if (1) begin : g
    wire n_t w = 4'h9;
  end
  assign o = g.w;
endmodule
