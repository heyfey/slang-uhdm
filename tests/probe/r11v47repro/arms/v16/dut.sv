module sub #(parameter int W = 8,
             parameter type it_t = struct packed { logic [7:0] x; logic [3:0] y; })
  (output logic [11:0] o);
  localparam it_t I = '{x: 8'd1, y: 4'd2};
  assign o = I;
endmodule
module dut;
  logic [11:0] a, b, c;
  sub #(.W(8)) u0 (.o(a));
  sub #(.W(9)) u1 (.o(b));
  sub #(.W(10)) u2 (.o(c));
endmodule
