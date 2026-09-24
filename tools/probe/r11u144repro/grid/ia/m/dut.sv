// § caSelLhsBareDecNoAdjust144
module t;
  typedef struct packed { logic [3:0] a; logic b; } s_t;
  s_t s;
  assign s.a[1] = 3;
endmodule
