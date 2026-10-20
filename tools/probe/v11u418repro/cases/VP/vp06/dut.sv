// § defGenPartSelBoundRefMember418
interface ifc #(parameter A = 8, parameter B = 2, parameter N = 1) ();
  typedef struct packed { logic [7:0] addr; logic [3:0] cid; } s_t;
  s_t p;
  wire [7:0] w;
  if (N == 1) begin
    assign w = p.addr[A-1:B];
  end
endinterface
module top; endmodule
