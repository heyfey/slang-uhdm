// § modArrBoundSelUnstored303
typedef struct packed { logic [3:0] a; logic [3:0] b; } s_t;
module subq (output logic z); assign z = 1'b1; endmodule
module top(output logic o);
  localparam s_t S = '{a: 4'd3, b: 4'd1};
  subq u_e [S.a[1:0]:0] ();
  assign o = 1'b0;
endmodule
