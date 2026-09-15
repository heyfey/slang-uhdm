typedef struct packed { logic [7:0] x; logic [3:0] y; } ov_t;
module sub #(parameter type it_t = struct packed { logic [7:0] x; logic [3:0] y; })
  (output logic [11:0] o);
  localparam it_t I = '{x: 8'd1, y: 4'd2};
  assign o = I;
endmodule
module dut;
  logic [11:0] a, b;
  sub u0 (.o(a));
  sub #(.it_t(ov_t)) u1 (.o(b));
endmodule
