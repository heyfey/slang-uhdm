// § evalFuncPkgStructMemberFolds237
// unsized decimal value read in a loop bound
package q;
  typedef struct packed { logic [7:0] e; logic [7:0] m; } s_t;
  localparam s_t S = '{3, 6};
  function automatic logic [31:0] fsum(int unsigned i);
    automatic logic [31:0] r = 0;
    for (int k = 0; k < S.e; k++) r += i;
    return r;
  endfunction
  function automatic logic [31:0] fw(int unsigned i);
    return fsum(i);
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
