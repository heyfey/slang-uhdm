// § namedOrderLinkedDeclines207v § namedUnlinkedWrittenOrder207 (the extern task prototype above the in-body caller comes from an included header)
package p;
  class F;
    `include "proto.svh"
    task run(int x);
      int y;
      tk(.c(y), .a(x));
      tk(.b(2), .c(y), .a(1));
    endtask
  endclass
  task F::tk(input int a, input int b = 3, output int c);
    c = a + b;
  endtask
endpackage
module top; endmodule
