// r10uvm57repro/a6_multi.sv -- MULTIPLE declarations in one block, and a
// declaration with an INITIALIZER, which may or may not also produce an
// assignment statement in the block's statement list.
class multi_c;
  static function int f(int obj);
    f = obj;
    if (obj == 0) begin
      string a, b;               // two on ONE decl statement
      int    c;
      a = "a"; b = "b"; c = 1;
      $display(a, b, c);
    end
    if (obj == 1) begin
      string init = "x";         // INITIALIZER
      int    ini2 = 7;
      $display(init, ini2);
    end
  endfunction
endclass

module a6_multi;
  int z;
  initial begin
    if (z == 0) begin
      string ma, mb;
      ma = "a"; mb = "b";
      $display(ma, mb);
    end
    if (z == 1) begin
      string minit = "x";
      $display(minit);
    end
  end
  multi_c mc;
  initial mc = null;
endmodule
