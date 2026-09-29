// § hpLvNewClassFirstElemSpan224
package p;
  class s; function new(string n = ""); endfunction endclass
  class r; s parent; endclass
  class m;
    function void f(r rw);
      rw.parent = new("default_parent_seq");
    endfunction
  endclass
endpackage
module top; endmodule
