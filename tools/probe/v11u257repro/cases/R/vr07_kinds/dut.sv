// § ifacePortMemberHighConnParent257 (members of several kinds: bit, int, enum, packed struct, logic vector)
typedef enum logic [1:0] {A, B, C} e_t;
typedef struct packed { logic a; logic [2:0] b; } s_t;
interface rif; bit bb; int ii; e_t ee; s_t ss; logic [3:0] lv;
  modport register(input bb, input ii, input ee, input ss, input lv); endinterface
module sink(input bit b, input int i, input e_t e, input s_t s, input logic [3:0] l, output logic o);
  assign o = b ^ i[0] ^ e[0] ^ s.a ^ l[0]; endmodule
module common(rif.register rp, output logic o); sink k(.b(rp.bb), .i(rp.ii), .e(rp.ee), .s(rp.ss), .l(rp.lv), .o(o)); endmodule
module top; rif r(); logic o; common u(.rp(r), .o(o)); endmodule
