// § idxCallPathAtDots191 — fresh: a range select and an indexed range over method calls, in a task and a nested operation
class F;
  int q[$];
  int r[$];
  task t(int b);
    r = q[0:q.size()-2];
    r = q[b-:q.size() / 2];
    r = {q[b:q.size()-1], q[q.size()-1:q.size()-1]};
  endtask
endclass
module top; endmodule
