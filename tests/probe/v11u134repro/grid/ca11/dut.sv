// § contAssignLhsTsUnparented134
interface ifc;
  typedef struct packed { logic [1:0] a; logic b; } s_t;
  s_t s;
  assign s = '{a: 2'b10, b: 1'b0};
endinterface
module top(output logic o);
  ifc i();
  assign o = i.s.b;
endmodule
