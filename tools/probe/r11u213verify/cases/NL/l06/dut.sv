// § namedOrderLinkedDeclines207v § namedUnlinkedWrittenOrder207 (the extern task prototype in the file above; the in-body CALL written by a macro and by an included file)
`define CALLTK(y, x) tk(.c(y), .b(5), .a(x));
package p;
  class F;
    extern task tk(input int a, input int b = 3, output int c);
    task run(int x);
      int y;
      `CALLTK(y, x)
      `include "call.svh"
    endtask
  endclass
  task F::tk(input int a, input int b = 3, output int c);
    c = a + b;
  endtask
endpackage
module top; endmodule
