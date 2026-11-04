// § modAggTfArgCloneFollows180
module top (input logic [31:0] i, output logic [11:0] o);
  typedef union packed { logic [31:0] w; logic [31:0] v; } op_t;
  function automatic logic [11:0] g (op_t op); g = op.w[11:0]; endfunction
  assign o = g(i);
endmodule
