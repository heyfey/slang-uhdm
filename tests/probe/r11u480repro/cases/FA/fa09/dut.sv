// § fixArrLocalNamedAggElemTs480 (module task, unpacked struct typedef)
module top;
  typedef struct { int k; bit [7:0] data; } op_t;
  task t(int n);
    op_t acc[2];
    acc[0].k = n;
  endtask
  initial t(1);
endmodule
