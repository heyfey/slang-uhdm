module top(output logic [11:0] o, output logic [11:0] q);
  typedef struct packed { logic [19:0] hi; logic [11:0] f; } op_t;
  function automatic logic [11:0] fa (op_t op); fa = op.f; endfunction
  function automatic logic [11:0] fb (op_t op); fb = ~op.f; endfunction
  localparam op_t OP = '{hi:'0, f: 12'h800};
  assign o = fa(OP);
  assign q = fb(OP);
endmodule
