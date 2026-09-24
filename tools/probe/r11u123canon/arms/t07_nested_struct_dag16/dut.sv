package p;
  typedef struct packed { logic a; logic b; } t0;
  typedef struct packed { t0 x; t0 y; } t1;
  typedef struct packed { t1 x; t1 y; } t2;
  typedef struct packed { t2 x; t2 y; } t3;
  typedef struct packed { t3 x; t3 y; } t4;
  typedef struct packed { t4 x; t4 y; } t5;
  typedef struct packed { t5 x; t5 y; } t6;
  typedef struct packed { t6 x; t6 y; } t7;
  typedef struct packed { t7 x; t7 y; } t8;
  typedef struct packed { t8 x; t8 y; } t9;
  typedef struct packed { t9 x; t9 y; } t10;
  typedef struct packed { t10 x; t10 y; } t11;
  typedef struct packed { t11 x; t11 y; } t12;
  typedef struct packed { t12 x; t12 y; } t13;
  typedef struct packed { t13 x; t13 y; } t14;
  typedef struct packed { t14 x; t14 y; } t15;
  typedef struct packed { t15 x; t15 y; } t16;
endpackage
module top(input p::t16 i, output p::t16 o);
  p::t16 a;
  assign a = i;
  assign o = a;
endmodule
