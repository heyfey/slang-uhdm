interface ifc #(parameter type idx_t = logic [1:0]) (input logic a);
  logic [1:0] y;
  if (1) begin : g
    assign y = idx_t'(a);
  end
endinterface
module top (input logic a, output logic [1:0] y);
  ifc u(.a(a));
  assign y = u.y;
endmodule
