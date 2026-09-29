// § fixedOuterAssocInnerReg223 — leading-fixed associative arrays of byte, bit vector, longint, a packed struct and an enum, and one with a fixed dimension after the associative
module top;
  typedef struct packed { logic [2:0] a; logic b; } ps_t;
  typedef enum logic [1:0] {E0, E1} e_t;
  byte       m1 [2][int];
  bit [5:0]  m2 [3][longint];
  longint    m3 [2][int][2];
  ps_t       m4 [4][int];
  e_t        m5 [2][int];
endmodule
