// § namedOrderLinkedDeclines207v § namedUnlinkedWrittenOrder207 (the extern task prototype above the in-body caller is written by a macro; a pure virtual task declared by a macro)
`define PROTO(n) extern task n(input int a, input int b = 3, output int c);
`define PVT(n) pure virtual task n(input int a, input int b, output int c);
package p;
  virtual class F;
    `PROTO(tk)
    `PVT(tv)
    task run(int x);
      int y;
      tk(.c(y), .a(x));
      tv(.c(y), .b(1), .a(x));
    endtask
  endclass
  task F::tk(input int a, input int b = 3, output int c);
    c = a + b;
  endtask
endpackage
module top; endmodule
