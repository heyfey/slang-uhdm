// v84x3 — ARGUMENT DIRECTIONS and the built-in output-ish calls.
module v84x3;
  class in3x;
    int    fld;
    int    arr[$];
    string s;
  endclass
  class c3x;
    in3x h;
    int  n;
    function void o(output int x); x = 1; endfunction
    function void io(inout int x); x = x + 1; endfunction
    function void r(ref int x); x = x + 1; endfunction
    function void f();
      this.o(this.h.fld);           // L15 output actual
      this.io(this.h.fld);          // L16 inout actual
      this.r(this.h.fld);           // L17 ref actual
      n = $sformatf("%0d", this.h.fld).len();  // L18 nested
      $display("%0d %0d", this.h.fld, this.h.arr.size()); // L19 two args
      n = $bits(this.h.fld);        // L20 $bits argument
      n = $signed(this.h.fld);      // L21 $signed argument
    endfunction
  endclass
endmodule
