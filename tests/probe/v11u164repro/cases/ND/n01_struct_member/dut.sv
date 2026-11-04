// § genNetDeclAssignLhsShared164 — a gen-if net declaration from a struct member (not a scope path)
module top(output wire o);
  typedef struct packed { logic f; logic g; } s_t;
  s_t s;
  if (1) begin : A
    wire z = s.f;
  end
  assign o = A.z;
endmodule
