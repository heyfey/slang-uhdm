// § evalFuncSelectKeepsCall148 (residue decode: const_cast_signext, measurement only)
typedef struct packed { logic [19:0] hi; logic [11:0] f; } op_t;
module top #(parameter op_t OP = '{hi:'0, f: 12'h800}) (output logic [11:0] o);
  function automatic logic [11:0] g(logic [11:0] x); g = x; endfunction
  assign o = g(OP.f);
endmodule
