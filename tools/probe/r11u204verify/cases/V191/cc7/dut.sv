// § evalFuncCastMemberKeepsCall191: struct-formal member reads bound to package parameters of a struct type (qualified and imported), an int type and an enum type
package pk;
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  typedef enum logic [7:0] {E0 = 8'h12, E1 = 8'h34} e_t;
  localparam s_t PS = '{a: 4'h7, b: 4'h8};
  localparam int PI = 33;
  localparam e_t PE = E1;
endpackage
module top import pk::*; (output logic [3:0] o1, o2, o3, o4);
  function automatic logic [3:0] h(s_t s); return s.a; endfunction
  assign o1 = h(pk::PS);
  assign o2 = h(PS);
  assign o3 = h(PI);
  assign o4 = h(PE);
endmodule
