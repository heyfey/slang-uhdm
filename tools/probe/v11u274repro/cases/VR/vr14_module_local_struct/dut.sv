// § elabMemberReadCopyChain274
module kid #(parameter int K = 1) (output logic [7:0] o);
  typedef struct packed { logic [7:0] a; logic [7:0] b; } in_t;
  typedef struct packed { in_t u; logic [7:0] d; } c_t;
  localparam c_t Q = '{u: '{a: 8'd1, b: 8'd2}, d: 8'd3};
  assign o = Q.u.a + K;
endmodule
module dut(output logic [7:0] o); kid #(.K(2)) k0 (.o(o)); endmodule
