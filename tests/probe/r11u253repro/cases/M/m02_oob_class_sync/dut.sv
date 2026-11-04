// § cloneMintParentHomeCall253
package p;
  class ph;
    ph succs[ph];
    extern function void sync();
  endclass
  function void ph::sync();
    int visited[ph];
    ph queue[$];
    queue.push_back(this);
    visited[this] = 1;
    while (queue.size()) begin
      ph node;
      node = queue.pop_front();
      foreach (node.succs[succ]) begin
        if (!visited.exists(succ)) begin
          queue.push_back(succ);
          visited[succ] = 1;
        end
      end
    end
  endfunction
endpackage
package q;
  import p::*;
endpackage
module top;
  import q::*;
endmodule
