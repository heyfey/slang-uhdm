// r10uvm57repro/a4_nested.sv -- NESTED unnamed blocks two deep with DIFFERENT
// names, then TWO SIBLING blocks at the same level declaring the SAME name.
// This is the cell where a naming law usually breaks.
class nest_c;
  static function int f(int obj);
    f = obj;
    if (obj == 0) begin
      string outer;
      outer = "o";
      if (obj == 0) begin
        string inner;
        inner = "i";
        $display(inner);
      end
      $display(outer);
    end
    if (obj == 1) begin
      string dup;
      dup = "d1";
      $display(dup);
    end
    if (obj == 2) begin
      string dup;              // SAME name, sibling block
      dup = "d2";
      $display(dup);
    end
  endfunction
endclass

module a4_nested;
  int r;
  initial begin
    if (r == 0) begin
      string mouter;
      mouter = "mo";
      if (r == 0) begin
        string minner;
        minner = "mi";
        $display(minner);
      end
      $display(mouter);
    end
    if (r == 1) begin
      string mdup;
      mdup = "m1";
      $display(mdup);
    end
    if (r == 2) begin
      string mdup;
      mdup = "m2";
      $display(mdup);
    end
  end
  nest_c nc;
  initial nc = null;
endmodule
