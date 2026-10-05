// § evalFuncPkgStructMemberFolds237
// a module-local function reads a package struct parameter qualified
package q;
  typedef struct packed { int unsigned e; int unsigned m; } enc_t;
  localparam enc_t S = '{5, 6};
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  function automatic int unsigned fw(int unsigned i);
    return q::S.e + i;
  endfunction
  assign o = fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
