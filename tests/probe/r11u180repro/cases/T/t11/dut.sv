// § modAggTfArgCloneFollows180
module top (output logic [11:0] o);
  typedef struct packed { logic [19:0] hi; logic [11:0] f; } op_t;
  function automatic logic [11:0] g (op_t op); g = op.f; endfunction
  localparam op_t P = '{hi:'0, f: 12'hFFF};
  assign o = g(P);
endmodule
