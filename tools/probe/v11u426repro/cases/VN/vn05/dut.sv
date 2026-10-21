// § namedTypeLocalTfItemOutsideClass426
class A;
  int j;
endclass
task t;
  input int i;
  A a1;
  a1 = new;
  a1.j = i;
endtask
module top;
  initial t(1);
endmodule
