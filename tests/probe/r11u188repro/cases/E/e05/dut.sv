// § evalFuncSelectKeepsCall148 (residue decode: const_cast_signext, measurement only)
module top(output logic [11:0] o);
  typedef struct packed { logic [19:0] hi; logic [11:0] f; } op_t;
  localparam op_t OP = '{hi:'0, f: 12'h800};
  function automatic logic [11:0] g(logic [11:0] x); g = OP.f + x; endfunction
  assign o = g(12'h1);
endmodule
