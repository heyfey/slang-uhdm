// § defGenPartSelBoundRefMember418
module m #(parameter A = 8, parameter B = 2, parameter N = 1) (input logic a);
  typedef struct packed { logic [7:0] addr; logic [3:0] cid; } s_t;
  s_t p;
  wire [7:0] w;
  for (genvar i = 0; i < 2; i++) begin : g
    assign w[i] = p.addr[i:i];
  end
endmodule
module top; endmodule
