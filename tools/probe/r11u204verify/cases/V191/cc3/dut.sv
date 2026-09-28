// § evalFuncCastMemberKeepsCall191: a member read of a struct formal bound to a sized literal actual (hex, decimal), to a non-struct parameter, and to a struct parameter (control)
module top(output logic [3:0] o1, output logic [3:0] o2, output logic [3:0] o3, output logic [3:0] o4);
  typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
  localparam logic [7:0] L = 8'h21;
  localparam s_t P = '{a: 4'd3, b: 4'd9};
  function automatic logic [3:0] h1(s_t s); return s.a; endfunction
  function automatic logic [3:0] h2(s_t s); h2 = s.b; endfunction
  assign o1 = h1(8'h21);
  assign o2 = h2(8'd33);
  assign o3 = h1(L);
  assign o4 = h2(P);
endmodule
