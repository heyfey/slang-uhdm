// § defGenPartSelBoundRefMember418
module m #(parameter A = 8, parameter B = 2, parameter N = 1) (input logic a);
  typedef struct packed { logic [7:0] addr; logic [3:0] cid; } s_t;
  s_t p;
  wire [7:0] w;
  if (N == 2) begin
    assign w = 0;
  end
  else begin
    assign w = p.addr[A-1:B];
  end
endmodule
module top; endmodule
