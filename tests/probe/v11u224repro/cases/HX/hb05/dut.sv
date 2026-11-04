// § hpLvNewClassFirstElemSpan224
package p;
  class s; function new(int a); endfunction endclass
  class r; s parent; endclass
  class m;
    r m_rw;
    function void f();
      m_rw.parent = new(3);
      m_rw.parent = new (4);
    endfunction
  endclass
endpackage
module top; endmodule
