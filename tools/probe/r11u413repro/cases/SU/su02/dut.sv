// § superMemberHierPath413
class P;
  int value;
  int w;
endclass
class L extends P;
  int value;
  task t(output int x);
    x = super.value;
  endtask
endclass
module top;
endmodule
