// § delayParenInnerExprSpan292
package p;
  class c;
    int x;
    task run(int d);
      #( d ) x = 1;
      #( d
      ) x = 2;
    endtask
  endclass
endpackage
module top; p::c o = new(); endmodule
