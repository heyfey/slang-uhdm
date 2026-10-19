// § unpStructArrElemVar412
module top(output logic [3:0] o);
  typedef struct packed { logic [3:0] a; } ps_t;
  typedef union { logic [3:0] a; logic [3:0] b; } u_t;
  ps_t p[2];
  u_t uu[2];
  ms_t_dummy d();
  assign p[0].a = 4'd1;
  assign o = p[0].a;
endmodule
module ms_t_dummy;
endmodule
