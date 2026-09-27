// § assocBracketPkgOnly186 (a $unit class: golden leaves the markers unlocated)
class e; endclass
class c;
  function void f();
    bit m[e];
    int idx;
    idx = 1;
  endfunction
endclass
module top; endmodule
