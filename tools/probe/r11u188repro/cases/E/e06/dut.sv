// § evalFuncSelectKeepsCall148 (residue decode: const_cast_signext, measurement only)
module top(output logic [11:0] o);
  typedef struct packed { logic [19:0] hi; logic [11:0] f; } op_t;
  function automatic logic [11:0] g(op_t op); return op.f; endfunction
  localparam op_t OP = '{hi:'0, f: 12'h800};
  assign o = g(OP);
endmodule
