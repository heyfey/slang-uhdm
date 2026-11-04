// § unboundEventImplicitNet403
module inner;
  task t; -> top.e; endtask
  initial t;
endmodule
module top;
  event e;
  inner i();
endmodule
