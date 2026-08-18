// v97_ca — the DEDUP-KEY refutation, widened: two DISTINCT parameterized
// classes that share a NAME (one per module) and a typedef name, each with two
// live specializations.  A string key would collapse across the two classes.
module m1_97ca;
  class tgt97ca;
    int q;
  endclass
  class dup97ca #(type T = int);
    typedef tgt97ca n97ca;
    n97ca h;
    T v;
  endclass
  class di97ca extends dup97ca #(int);
    function void f(n97ca p); h = p; endfunction
  endclass
  class db97ca extends dup97ca #(byte);
    function void f(n97ca p); h = p; endfunction
  endclass
endmodule
module m2_97ca;
  class tgt97ca;
    int q;
  endclass
  class dup97ca #(type T = int);
    typedef tgt97ca n97ca;
    n97ca h;
    T v;
  endclass
  class di97ca extends dup97ca #(int);
    function void f(n97ca p); h = p; endfunction
  endclass
  class db97ca extends dup97ca #(byte);
    function void f(n97ca p); h = p; endfunction
  endclass
endmodule
