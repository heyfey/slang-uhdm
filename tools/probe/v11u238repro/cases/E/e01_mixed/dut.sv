// § cloneForIncBindsHomeVar238
// named and positional calls into a looping home function from a clone, an extern method body below its caller,
// a pure virtual prototype, a class specialization in a bound, an implicit net in the module
package p;
  class pc #(int W = 4); localparam int K = W; endclass
  function int h(int n, int base = 1);
    int c;
    c = base;
    for (int b = 0; b < n; b++) c += b;
    return c;
  endfunction
  virtual class vb;
    pure virtual function int pv(int x);
  endclass
  class impl extends vb;
    string m_name;
    extern function int use_it();
    extern virtual function int pv(int x);
  endclass
  function int impl::use_it();
    int s;
    s = pv(2);
    foreach (m_name[i]) s++;
    for (int j = 0; j < 2; j++) s += h(.n(j));
    return s;
  endfunction
  function int impl::pv(int x);
    for (int k = 0; k < x; k++) x--;
    return x;
  endfunction
endpackage
package q;
  import p::*;
  function int qh(int n);
    impl o = new;
    return h(.n(n), .base(2)) + h(n) + o.use_it();
  endfunction
endpackage
module top(input logic a, input logic b);
  logic [p::pc#(8)::K-1:0] w;
  assign imp = a & b;
  int r;
  initial r = q::qh(3);
endmodule
