// § genScopeClassVarListed206
class c;
endclass
module chk (input logic a);
  if (1) begin : g
    c q;
  end
endmodule
module e18 (input logic a);
  logic b;
  assign b = a;
endmodule
bind e18 chk u_chk (.a(b));
