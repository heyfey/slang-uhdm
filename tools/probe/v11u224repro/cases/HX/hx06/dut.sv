// § hpLvNewClassFirstElemSpan224
package p;
  class s; int x; endclass
  class r; s parent; endclass
  class m;
    task t(r rw);
      fork
        rw.parent = new;
      join_none
    endtask
  endclass
endpackage
module top; endmodule
