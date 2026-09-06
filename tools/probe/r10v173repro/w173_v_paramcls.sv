// r10v173 arm V — PARAMETERIZED CLASSES, SPECIALIZATIONS, NESTED AND VIRTUAL
// CLASSES inside a package.  A specialization is a listing of its own, so a
// call emitted from inside one may root somewhere the gate's parent-walk does
// not recognise as a package of `AllPackages`.  Three specializations, so a
// gate that keys on "the first one it finds" is visible.
package brazier_pkg;

  function automatic int unsigned scorch(int unsigned n);
    return n + 17;
  endfunction

  virtual class Kiln #(parameter int unsigned WIDTH = 8);
    int unsigned fired;
    function new();
      fired = scorch(WIDTH);                       // bare, inside a specialization
    endfunction
    virtual function int unsigned bake(int unsigned n);
      return scorch(n) + brazier_pkg::scorch(WIDTH);
    endfunction
    pure virtual function int unsigned glaze(int unsigned n);
  endclass

  class Crucible #(parameter int unsigned WIDTH = 8) extends Kiln #(WIDTH);
    // a NESTED class inside a parameterized class
    class Slag;
      int unsigned dross;
      function new(); dross = brazier_pkg::scorch(1); endfunction
    endclass
    Slag sl;
    function new();
      super.new();
      sl = new();
    endfunction
    virtual function int unsigned glaze(int unsigned n);
      return scorch(n) + super.bake(n);
    endfunction
  endclass

  typedef Crucible #(4)  crucible4_t;
  typedef Crucible #(16) crucible16_t;
  typedef Crucible #(32) crucible32_t;

  function automatic int unsigned smelt(int unsigned n);
    crucible4_t  c4;
    crucible16_t c16;
    c4  = new();
    c16 = new();
    return c4.glaze(n) + c16.glaze(n) + scorch(n) + brazier_pkg::scorch(n);
  endfunction

endpackage

module brazier_top (output int unsigned b1, output int unsigned b2);
  import brazier_pkg::*;
  crucible32_t c32;
  int unsigned r;
  initial begin
    c32 = new();
    r = c32.glaze(3);
  end
  assign b1 = smelt(5);
  assign b2 = r + brazier_pkg::scorch(6);
endmodule
