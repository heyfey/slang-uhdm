// r10v167 arm L - `this.` / `super.` / static `Class::m()` shelled calls.
package pl167;
  class basel167;
    int r;
    function int bf167(int a, int b = 0, int c = 0);
      return a + b + c;
    endfunction
    static function int sf167(int a, int b = 0);
      return a + b;
    endfunction
    function new(int a = 1, int b = 2);
      r = a + b;
    endfunction
  endclass
  class kidl167 #(type T167 = int) extends basel167;
    int q;
    function new(int a = 3);
      super.new(a);
    endfunction
    function void goL();
      q = this.bf167(1);
      q = this.bf167(T167::nm167);
      q = this.bf167(.a(T167::nm167), .c(9));
      q = super.bf167(1);
      q = super.bf167(T167::nm167);
      q = super.bf167(.a(T167::nm167), .c(9));
      q = basel167::sf167(1);
      q = basel167::sf167(T167::nm167);
    endfunction
  endclass
endpackage
