// § hpLvNewClassFirstElemSpan224
package p;
  class s; endclass
  class r; s parent; endclass
  class m;
    task t(r rw);
      rw.parent <= new;
    endtask
  endclass
endpackage
module top; endmodule
