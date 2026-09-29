// § fixedOuterAssocInnerReg223
typedef struct packed { logic [3:0] a; logic b; } s_t;
class k; int v; endclass
module dut;
  s_t ms [3][int];
endmodule
