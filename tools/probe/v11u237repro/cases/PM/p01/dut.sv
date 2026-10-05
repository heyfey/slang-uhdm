// § evalFuncPkgStructMemberFolds237
// unsized based hex member value
package q;
  typedef struct packed { logic [7:0] e; logic [7:0] m; } s_t;
  localparam s_t S = '{'h5, 'h6};
  function automatic logic [31:0] fw(int unsigned i);
    return S.e + i;
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
