// § hpLvNewClassFirstElemSpan224 (inside fork/join in a module task)
class s; endclass
class r; s parent; endclass
module top;
  r rw;
  task t();
    rw = new;
    fork
      rw.parent = new;
    join
  endtask
  initial t();
endmodule
