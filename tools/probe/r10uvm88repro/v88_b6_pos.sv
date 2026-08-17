// v88 b6 — POSITIONS THE IMPLEMENTER'S a3 DID NOT SPELL: concat, $display with
// several args, ternary, inside-set, an index expression, a method call ON the
// package variable, a continuous assignment in a module, and a read from a
// FOREIGN package's function.
package p6;
  const string c6 = "C6";
  int          n6 = 6;
  string       arr6[4];
  class k6;
    string s; int i; logic [7:0] b;
    function void inb6();
      s = {c6, "x", c6};                 // CONCAT
      $display("%s %0d %s", c6, n6, c6); // $display, three args
      s = (n6 > 2) ? c6 : "y";           // TERNARY, both arms
      if (n6 inside {1,2,6}) i = 1;      // INSIDE set
      s = arr6[n6];                      // INDEX expression AND the array
      i = c6.len();                      // METHOD CALL on the package var
      case (n6)
        6:       i = n6;                 // CASE selector + item
        default: i = 0;
      endcase
      i = f6(c6);                        // call ARGUMENT (the head's shape)
    endfunction
    function int f6(string t); return t.len(); endfunction
    extern function void oob6();
  endclass
  function void k6::oob6();
    s = {c6, "x"}; $display(c6, n6); i = c6.len(); i = f6(c6); s = arr6[n6];
  endfunction
endpackage
package r6;
  import p6::*;
  function int rf6();                     // FOREIGN package function
    return n6 + p6::n6;
  endfunction
  class rk6;
    string s;
    function void inb_r6(); s = c6; s = p6::c6; endfunction
  endclass
endpackage
module topb6;
  import p6::*;
  wire [7:0] w6;
  assign w6 = n6[7:0];                    // CONT-ASSIGN in a module
  p6::k6 h; r6::rk6 rh;
  initial begin h = new(); rh = new(); h.inb6(); rh.inb_r6(); void'(r6::rf6()); end
endmodule
