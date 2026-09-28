// § evalFuncCastMemberKeepsCall191: which actuals of a struct formal whose member the body reads fold in golden: a concatenation, an operation, a size cast, a fill literal, an int localparam, a qualified package parameter, a nested call
package pk; parameter logic [7:0] Q = 8'h34; endpackage
module top(output logic [3:0] o1, o2, o3, o4, o5, o6, o7);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam int I = 33;
  function automatic logic [3:0] h(s_t s); return s.a; endfunction
  function automatic logic [7:0] id(logic [7:0] x); return x; endfunction
  assign o1 = h({4'd1, 4'd2});
  assign o2 = h(8'h20 + 8'h1);
  assign o3 = h(8'(33));
  assign o4 = h('1);
  assign o5 = h(I);
  assign o6 = h(pk::Q);
  assign o7 = h(id(8'h21));
endmodule
