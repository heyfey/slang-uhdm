// § dynAssocMemberSpanToDim295
module top(output logic o);
  typedef struct { logic [7:0] m[
    string
  ]; } s_t;
  s_t s;
  assign o = 1'b0;
endmodule
