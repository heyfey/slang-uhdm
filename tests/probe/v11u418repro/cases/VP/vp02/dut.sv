// § defGenPartSelBoundRefMember418
module m #(parameter A = 7, parameter B = 2, parameter N = 1) (input logic a);
  typedef struct packed { logic [7:0] addr; logic [3:0] cid; } s_t;
  s_t p [2];
  wire [7:0] w;
  if (N == 1) begin
    assign w = p[0].addr[A:B];
  end
endmodule
module top; endmodule
