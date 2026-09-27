// § invalidStmtAnchorSyntax181 (r11u190: an unbound item as the second of two in a task, and an unbound assignment right side after a bound item)
package p;
  class conc;
    static function conc get(); return null; endfunction
    function void note(conc w, string s); endfunction
  endclass
  class gen #(type T = int);
    int n;
    task t(string nm);
      conc f = conc::get();
      f.note(T::get(), nm);
    endtask
    function void g(string nm);
      n = 1;
      n = T::size(nm);
    endfunction
  endclass
endpackage
module top;
endmodule
