// r10uvm46 arm t64c, GOLDEN-ONLY cell — a class-item qualifier plus a written
// `static` LIFETIME.  Split out of dut.sv because slang enforces the LRM here
// ("class methods cannot have static lifetime") and rejects the file, so this
// cell can only ever be read on the golden side.
// MEASURED: golden gives `function ''` owner=class_defn 'c66c'
// full='p66c::c66c' nio=0 stmt=- ret=SET method=1 vis=3 autom=0 — the same
// artifact as `automatic`, confirming the distinguisher is "a WRITTEN lifetime",
// not the word `automatic`.
package p66c;
  class c66c;
    local function static int f_loc_static(int a);
      return a;
    endfunction
  endclass
endpackage

module t64c_c66c;
  initial begin
    p66c::c66c h;
    h = new();
  end
endmodule
