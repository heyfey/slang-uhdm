// § genNetDeclAssignLhsShared164 — a gen-if net declaration from an interface signal
interface itf;
  logic s;
endinterface
module top(output wire o);
  itf i();
  if (1) begin : A
    wire z = i.s;
  end
  assign o = A.z;
endmodule
