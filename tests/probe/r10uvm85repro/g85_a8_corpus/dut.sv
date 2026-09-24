// r10uvm85 arm a8 — THE CORPUS SHAPE.  A PACKAGE class with an OUT-OF-BODY
// method and its IN-BODY twin, both writing the head statement inside a
// `for`+`if` nest, so the ARGUMENT's binding (golden binds the loop variable
// out of body and leaves the formal bare) is measured in both bodies and in
// both the package view and the module-hoisted view.
package p85a8;
  class c8;
    string   sequences[$];
    int      n;
    extern function void oob8(string t);
    function void inb8(string t);
      for (int i = 0; i < this.sequences.size(); i++) begin
        if (this.sequences[i] == t)
          this.sequences.delete(i);      // L14 IN-BODY, loop-var actual
      end
      this.sequences.push_back(t);       // L16 IN-BODY, FORMAL actual
      this.n = 0;
    endfunction
  endclass
  function void c8::oob8(string t);
    for (int i = 0; i < this.sequences.size(); i++) begin
      if (this.sequences[i] == t)
        this.sequences.delete(i);        // L23 OUT-OF-BODY, loop-var actual
    end
    this.sequences.push_back(t);         // L25 OUT-OF-BODY, FORMAL actual
    this.n = 1;
  endfunction
endpackage
module g85a8;
  import p85a8::*;
  c8 h;
endmodule
