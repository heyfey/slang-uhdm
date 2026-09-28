// § bitSelMethodCallIdxSpan207: built-in methods as indices: string len, queue size, associative num, enum first and next, dynamic array size
package p;
typedef enum {A, B, C2} e_t;
class C;
  int m[int];
  int q[$];
  int d[];
  int aa[string];
  string s;
  e_t e;
  function int f();
    return m[s.len()] + m[q.size()] + m[aa.num()] + m[e.first()] + m[e.next()] + m[d.size()] + m[s.toupper().len()];
  endfunction
endclass
endpackage
module top; endmodule
