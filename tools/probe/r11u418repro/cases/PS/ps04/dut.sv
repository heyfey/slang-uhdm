// § defGenPartSelBoundRefMember418
module m #(parameter A = 8, parameter B = 2, parameter N = 1) (input logic a);
  typedef struct packed { logic [7:0] addr; logic [3:0] cid; } s_t;
  s_t p;
  wire [7:0] w;
  if (N == 1) begin
    if (A == 8) begin
      assign w = {
        {(A-B){1'b0}},
        p.addr[A-1:B],
        {B{1'b0}}
      };
    end
    else begin
      assign w = {p.addr[A-1:B+N], 1'b0};
    end
  end
endmodule
module top; endmodule
