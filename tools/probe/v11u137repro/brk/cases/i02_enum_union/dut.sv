// § aliasCloneTakesTargetFile137
module dut(output o);
  typedef enum logic {X, Y} e;
  typedef e ea [2];
  typedef union packed { logic a; logic b; } u;
  typedef u ua [3];
  ea p;
  ua q;
  assign o = q[0].a;
endmodule
