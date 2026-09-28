module top(output logic [1:0] o);
  localparam type s_t = struct packed { logic [1:0] a; logic b; };
  localparam s_t P = '{a: 2'b10, b: 1'b1};
  assign o = P.a;
endmodule
