// § bitSelMethodCallIdxSpan207: indices written as class-specialization static calls, a package-qualified specialization, a chained handle and a method of this.o, beside an implicit net in a continuous assignment
package p;
class K #(int W = 1);
  static function int sf(int a); return a + W; endfunction
  int v;
  function int gi(int a); return a; endfunction
endclass
class H; K #(2) o; function int gi(int a); return a; endfunction endclass
class U;
  int m [8];
  K #(2) o;
  H h;
  function int f(int i);
    int r;
    r = m[K#(2)::sf(i)] + m[p::K#(3)::sf(1)];
    r += m[h.o.gi(i)] + m[this.o.gi(2)] + m[this.h.gi(i)];
    return r;
  endfunction
endclass
endpackage
module top(input logic [3:0] a, output logic y);
  logic [7:0] mem;
  assign imp = a[0];
  assign y = mem[p::K#(2)::sf(1)] ^ imp;
endmodule
