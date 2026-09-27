// § modAggTfArgCloneFollows180
module top (input logic [1:0] i, output logic o);
  typedef enum logic [1:0] { A, B, C } e_t;
  function automatic logic g (e_t e); g = (e == B); endfunction
  assign o = g(e_t'(i));
endmodule
