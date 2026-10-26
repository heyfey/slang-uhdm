// § caPlainLhsUnsizedClone438 (control: a user call the reduce leg folds, v11u417 VH/vh12's shape)
module sub (input logic [3:0] i, output logic [3:0] o);
  typedef struct packed { logic [63:0] d; } s_t;
  function automatic logic [3:0] f(s_t s, logic [3:0] k);
    return s.d[(k*2)+:4];
  endfunction
  assign o = f('0, i);
endmodule
module top (input logic [3:0] i, output logic [3:0] o);
  sub u(.i(i), .o(o));
endmodule
