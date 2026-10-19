// § unboundEventImplicitNet403
class C;
  task t; -> top.e; endtask
endclass
module top;
  event e;
  C c = new;
endmodule
