// § newLhsBitSelAtIndex181 — class-handle array elements assigned new in a package class method and a module task
package p;
  class R; int a; endclass
  class E; R rs [4]; function void build(int k); rs[k] = new; endfunction endclass
endpackage
module top;
  import p::*;
  R ms [4];
  task automatic t(int k); ms[k] = new; endtask
  initial begin E e = new; e.build(1); t(2); end
endmodule
