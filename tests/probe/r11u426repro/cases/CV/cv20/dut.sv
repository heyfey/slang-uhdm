// § namedTypeLocalTfItemOutsideClass426
typedef struct { int a; } box_t;
module top;
  task t;
    input int x;
    box_t r;
    r.a = x;
  endtask
endmodule
