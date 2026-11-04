// § fixArrLocalNamedAggElemTs480 (struct local array in a task of a program)
program prg;
  typedef struct { int k; int d; } op_t;
  task t();
    op_t acc[2];
    acc[0].k = 1;
  endtask
  initial t();
endprogram
module top; prg p(); endmodule
