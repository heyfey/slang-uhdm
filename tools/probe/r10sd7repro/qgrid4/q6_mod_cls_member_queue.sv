// q6 — the same class data member, but the class lives in a MODULE, so there is
// no home package at all.  Separates "class member" from "no package".
module top6;
  typedef struct { int a; } s6_t;
  class c6;
    s6_t q6[$];
  endclass
  c6 h6;
  initial h6 = new();
endmodule
