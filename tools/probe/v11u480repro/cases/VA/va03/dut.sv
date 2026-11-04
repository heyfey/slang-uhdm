// § fixArrLocalNamedAggElemTs480 (declaring module nested two levels, static task)
module leaf;
  typedef struct { int k; byte data; } op_t;
  task t(output int o);
    op_t acc[3];
    acc[2].k = 5;
    o = acc[2].k;
  endtask
  int x;
  initial t(x);
endmodule
module mid; leaf l(); endmodule
module top; mid m(); endmodule
