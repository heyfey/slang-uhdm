// § tpAnonStructCopySpanAtKeyword167
module top #(parameter type it_t = struct packed { logic [7:0] x; logic [7:0] y; })
  (input logic a, output it_t o);
  localparam it_t I = '{x: 8'd1, y: 8'd2};
  assign o = a ? I : '0;
endmodule
