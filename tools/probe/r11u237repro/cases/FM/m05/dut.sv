// § evalFuncPkgStructMemberFolds237
// packed union parameter member
package q;
  typedef union packed { logic [31:0] w; logic [3:0][7:0] b; } u_t;
  localparam u_t S = 32'h01020304;
  function automatic int unsigned fw(int unsigned i);
    return S.w + i;
  endfunction
endpackage
module sub #(parameter int unsigned M = 0) (output logic [31:0] o);
  assign o = q::fw(M);
endmodule
module top (output logic [31:0] o);
  sub #(.M(2)) u (.o(o));
endmodule
