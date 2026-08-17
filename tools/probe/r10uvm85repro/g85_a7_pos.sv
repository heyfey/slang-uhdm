// r10uvm85 arm a7 — POSITION.  Every statement position a Subroutine_call_
// statement can occupy, plus the `void'(...)` cast form (which the parser also
// makes a Subroutine_call_statement, so it takes the same arm).
module g85a7;
  class c7;
    int      q[$];
    int      n;
    task tk7(int k);
      this.q.delete(k);              // L9  TASK body
      fork
        this.q.push_back(k);         // L11 FORK arm
      join_none
      if (k > 0)
        this.q.delete(0);            // L14 IF body
      else
        this.q.delete(1);            // L16 ELSE body
      for (int i = 0; i < 2; i++)
        this.q.delete(i);            // L18 FOR body, loop-var actual
      while (this.n > 0)
        this.q.delete(0);            // L20 WHILE body
      case (k)
        0: this.q.delete(0);         // L22 CASE item
        default: this.q.delete(1);   // L23
      endcase
      begin : nb7
        this.q.delete(k);            // L26 NAMED block
      end
      void'(this.q.size());          // L28 cast-wrapped, 0 args
      void'(this.q.pop_front());     // L29 cast-wrapped, 0 args
    endtask
  endclass
endmodule
