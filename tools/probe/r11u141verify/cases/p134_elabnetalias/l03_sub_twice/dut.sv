// § elabNetTdCloneNoAlias134
// case l03: a module with a vector-typedef net instantiated twice with different parameters
module sub #(parameter int W = 4) (output logic [W-1:0] o);
  typedef logic [W-1:0] n_t;
  wire n_t w = '1;
  assign o = w;
endmodule
module top(output logic [3:0] o1, output logic [5:0] o2);
  sub #(.W(4)) a(.o(o1));
  sub #(.W(6)) b(.o(o2));
endmodule
