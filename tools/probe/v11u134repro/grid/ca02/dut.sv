// § contAssignLhsTsUnparented134
typedef struct packed { logic [1:0] a; logic b; } s_t;
interface ifc;
  s_t s;
  assign s = '{a: 2'b01, b: 1'b1};
endinterface
module top(output logic o);
  ifc i();
  assign o = i.s.b;
endmodule
