// § cloneTfItemLocalOwnVar253 (a paren-less task: a local declared before the io, another after)
package p;
  task automatic t;
    int x;
    input int a;
    int y;
    x = a;
    y = x;
  endtask
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
