// § evalFuncCastMemberKeepsCall191: struct-formal member reads bound to operations over a module localparam, a wildcard-imported package parameter, a module port parameter and a concatenation holding a parameter select
package pk; parameter logic [7:0] Q = 8'h34; endpackage
module top import pk::*; #(parameter logic [7:0] PP = 8'h56) (output logic [3:0] o1, o2, o3, o4, o5);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam logic [7:0] L = 8'h21;
  function automatic logic [3:0] h(s_t s); return s.a; endfunction
  assign o1 = h(L + 8'h0);
  assign o2 = h(Q);
  assign o3 = h(PP);
  assign o4 = h({L[7:4], 4'd1});
  assign o5 = h(Q + 8'h1);
endmodule
