// § opCtxRefArgBare201
module top(input logic [3:0] a, output logic [7:0] o);
  typedef struct packed { logic [3:0] x; logic [3:0] y; } s_t;
  function automatic logic [3:0] f(input logic [3:0] v); return v + 1; endfunction
  s_t s;
  assign s = {f(a) + 4'd1, 4'd2};
  assign o = s;
endmodule
