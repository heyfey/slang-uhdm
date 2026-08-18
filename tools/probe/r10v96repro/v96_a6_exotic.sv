// r10v96 arm 6 — the NON-moving exotic targets (must stay byte-identical):
// string / chandle / event / class handles / parameterized class / $cast.
package v96p6;
  class B; int x; endclass
  class P #(parameter int W = 3); bit [W-1:0] y; endclass
  typedef P#(5) p5_t;
  typedef chandle ch_t;
  typedef string  str_t;
  function automatic void f6();
    logic [31:0] v = 32'h41;
    string       s;
    chandle      c;
    B            bh;
    p5_t         ph;
    s = string'(v);
    s = str_t'(v);
    bh = B'(bh);
    ph = p5_t'(ph);
    $display("%s %0d", s, $bits(v));
  endfunction
endpackage

module v96m6;
  logic [31:0] v;
  string s;
  initial begin
    s = string'(v);                 // module-scope string cast (R2's shape)
    $display("%s %0d %0d", s, $signed(v), $unsigned(v));
    $display("%0d %0d", signed'(v), unsigned'(v));
  end
endmodule
