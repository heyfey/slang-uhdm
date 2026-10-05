// § evalFuncPkgStructMemberFolds237
// a default pattern value
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t S = '{default: 7};
  function automatic int unsigned fw(int unsigned i);
    return S.e + i;
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
