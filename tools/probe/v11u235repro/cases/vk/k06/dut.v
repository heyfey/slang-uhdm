// § vlogEnumBaseKwSpan235
module top(output [2:0] o, output [1:0] p);
  function [2:0] f(input [2:0] a);
    enum bit [2:0] {X0, X1} loc;
    begin loc = X1; f = a ^ loc; end
  endfunction
  typedef struct packed { logic [1:0] a; } s_t;
  typedef enum logic [1:0] {P, Q} pq_t;
  pq_t z;
  assign o = f(3'd1);
  assign p = z;
endmodule
