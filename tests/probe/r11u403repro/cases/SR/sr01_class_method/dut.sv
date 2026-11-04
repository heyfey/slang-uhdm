// § stdRandomizeIsScopeRef403
class a;
  function int f(int y);
    int x, s;
    s = std::randomize(x);
    s = std::randomize(x) with {x > 0; x < y;};
    return s;
  endfunction
endclass
module top; endmodule
