// § evalFuncPkgStructMemberFolds237
// wildcard-imported package struct parameter, no formal read
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t S = '{5, 6};
  function automatic int unsigned fw(int unsigned i);
    return S.e;
  endfunction
endpackage
module sub import q::*; #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
