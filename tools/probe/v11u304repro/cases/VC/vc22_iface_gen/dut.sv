// § genCaCastTdAliasScopedName304
interface ifc (input logic [3:0] a);
  typedef logic [1:0] idx_t;
  logic [1:0] y;
  if (1) begin : g
    assign y = idx_t'(a) + 2'd1;
  end
endinterface
module top (input logic [3:0] a, output logic [1:0] y);
  ifc u (.a(a));
  assign y = u.y;
endmodule
