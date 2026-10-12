// § dynAssocMemberSpanToDim295
`define IDX string
module top(output logic o);
  typedef struct { int m[`IDX]; } s_t;
  s_t s;
  assign o = 1'b0;
endmodule
