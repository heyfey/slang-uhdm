// § evalFuncPkgStructMemberFolds237
// a module parameter member read (control: the M arm keeps)
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
endpackage
module sub #(parameter int unsigned M = 0, parameter q::enc_t S = '{5, 6}) (output logic [31:0] o);
  function automatic int unsigned fw(int unsigned i);
    return S.e + i;
  endfunction
  assign o = fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
