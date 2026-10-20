// § defGenPartSelBoundRefMember418
module m #(parameter A = 8, parameter B = 2, parameter N = 1) (input logic a);
  typedef struct packed { logic [7:0] addr; logic [3:0] cid; } s_t;
  typedef struct packed { s_t s; logic v; } o_t;
  o_t p;
  wire [7:0] w;
  if (N == 1) begin
    assign w = p.s.addr[A-1:B];
  end
endmodule
module top; endmodule
