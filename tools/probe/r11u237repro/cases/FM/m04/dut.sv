// § evalFuncPkgStructMemberFolds237
// nested member
package q;
  typedef struct packed { int unsigned e; int unsigned m; } in_t;
  typedef struct packed { in_t in; logic [7:0] x; } enc_t;
  localparam enc_t S = '{'{5, 6}, 8'd9};
  function automatic int unsigned fw(int unsigned i);
    return S.in.e + i;
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
