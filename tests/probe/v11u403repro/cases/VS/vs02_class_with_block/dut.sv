// § stdRandomizeIsScopeRef403
class C;
  int v;
  function void f();
    int ok;
    ok = std::randomize(v) with { v inside {[1:5]}; };
  endfunction
endclass
module top; C c = new; endmodule
