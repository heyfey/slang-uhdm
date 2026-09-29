// § hpLvNewClassFirstElemSpan224 (a macro as the constructor argument)
`define NAME "nm"
package p;
  class s; function new(string n = ""); endfunction endclass
  class r; s parent; endclass
  class t;
    r rw;
    function void f();
      rw = new;
      rw.parent = new(`NAME);
    endfunction
  endclass
endpackage
module top; endmodule
