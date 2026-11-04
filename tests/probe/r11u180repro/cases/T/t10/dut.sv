// § modAggTfArgCloneFollows180
module top (input logic [31:0] i, output logic [11:0] o);
  typedef struct packed { logic [19:0] hi; logic [11:0] f; } op_t;
  op_t v;
  function automatic logic [11:0] g (op_t op); g = op.f; endfunction
  assign v = i;
  assign o = g(v);
endmodule
