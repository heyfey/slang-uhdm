// § dynAssocMemberSpanToDim295
module top(output logic o);
  typedef union { int a; int m[int]; } u_t;
  u_t u;
  assign o = 1'b0;
endmodule
