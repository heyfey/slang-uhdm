// § castInvalidOperandSyntax292
package p;
  class gen #(type T = int, int W = 4);
    int q[$];
    function int x1();
      if (int'(T::get()) > 0) return 1;
      q.push_back(int'(T::get()));
      foreach (q[i]) q[i] = W'(T::get());
      return longint'(T::get());
    endfunction
    task t(); #1; endtask
  endclass
endpackage
module top; endmodule
