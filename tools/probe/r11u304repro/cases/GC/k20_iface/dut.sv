// § genCaCastTdAliasScopedName304
interface ifc (input logic a);
  typedef logic [1:0] idx_t;
  logic [1:0] y;
  if (1) begin : g
    assign y = idx_t'(a);
  end
endinterface
module top (input logic a, output logic [1:0] o);
  ifc u(.a(a));
  assign o = u.y;
endmodule
