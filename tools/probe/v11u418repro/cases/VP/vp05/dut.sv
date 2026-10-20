// § defGenPartSelBoundRefMember418
package pk; parameter A = 8; endpackage
module m #(parameter B = 2, parameter N = 1) (input logic a);
  typedef struct packed { logic [7:0] addr; logic [3:0] cid; } s_t;
  s_t p;
  wire [7:0] w;
  if (N == 1) begin
    assign w = p.addr[pk::A-1:B];
  end
endmodule
module top; endmodule
