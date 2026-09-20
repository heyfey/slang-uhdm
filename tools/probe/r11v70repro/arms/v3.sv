typedef struct packed { logic [3:0] a; logic [3:0] b; } l2_t;
module v3 (output logic [7:0] o);
  localparam l2_t A = l2_t'{a: 4'd1, b: 4'd2};
  assign o = A;
endmodule
