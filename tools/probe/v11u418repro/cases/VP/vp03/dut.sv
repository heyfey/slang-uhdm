// § defGenPartSelBoundRefMember418
module sub (input logic [7:0] i);
endmodule
module m #(parameter A = 8, parameter B = 2, parameter N = 1) (input logic a);
  typedef struct packed { logic [7:0] addr; logic [3:0] cid; } s_t;
  s_t p;
  if (N == 1) begin : g
    sub u (.i({2'b0, p.addr[A-1:B]}));
  end
endmodule
module top; endmodule
