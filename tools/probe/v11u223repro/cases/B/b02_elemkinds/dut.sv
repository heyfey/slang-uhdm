// § fixedOuterAssocInnerReg223
typedef struct packed { logic [3:0] a; logic b; } s_t;
class k; int v; endclass
module dut;
  s_t ms [3][int];
  k mc [2][string];
  bit [3:0] mb [2][byte];
  int mw [2][*];
  string mstr [2][int];
  logic mq [2][int][$];
endmodule
