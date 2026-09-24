// r10uvm84 arm b3 — the CORPUS shape: package class, OUT-OF-BODY method,
// `for (int i = 0; i < this.<member>.size(); i++)` plus the in-body twin.
package p84b3;
  class c3b;
    string sequences[$];
    int    n;
    extern function void remove_one(string t);
    function void inbody(string t);
      for (int i = 0; i < this.sequences.size(); i++) begin
        if (this.sequences[i] == t)
          this.sequences.delete(i);
      end
    endfunction
  endclass
  function void c3b::remove_one(string t);
    for (int i = 0; i < this.sequences.size(); i++) begin
      if (this.sequences[i] == t)
        this.sequences.delete(i);
    end
  endfunction
endpackage
module g84b3;
  import p84b3::*;
  c3b h;
endmodule
