// § invalidStmtAnchorSyntax181 (r11u190: two and three unbound items in a parameterized class method, and an unbound item inside a nested begin block)
package p;
  class conc;
    static function conc get(); return null; endfunction
    function void note(conc w, string s); endfunction
  endclass
  class gen #(type T = int);
    function void two(string nm);
      conc f = conc::get();
      f.note(T::get(), nm);
      f.note(T::get(), {nm, "x"});
    endfunction
    function void three(string nm);
      conc f = conc::get();
      f.note(T::get(), nm);
      f.note(T::other(), nm);
      f.note(T::get(), nm);
    endfunction
    task nested(string nm);
      conc f = conc::get();
      begin
        f.note(T::get(), nm);
        if (nm != "") begin
          f.note(T::get(), nm);
        end
      end
    endtask
  endclass
endpackage
module top;
endmodule
