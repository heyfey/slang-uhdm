// § dynAssocMemberSpanToDim295
interface ifc;
  typedef struct { int m[string]; } s_t;
  s_t s;
endinterface
module top(output logic o);
  ifc i();
  assign o = 1'b0;
endmodule
