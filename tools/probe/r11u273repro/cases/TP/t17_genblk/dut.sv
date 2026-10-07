// § typeParamStructLastNetParent273
module top(input logic a, output logic [7:0] o);
  localparam type my_t = struct packed { logic [7:0] a; logic b; };
  if (1) begin : g
    my_t s;
    always_comb s = '{a: {7'd0, a}, b: a};
  end
  assign o = g.s.a;
endmodule
