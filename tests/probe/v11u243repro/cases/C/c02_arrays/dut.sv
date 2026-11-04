// § lawSStringTd243
// a queue, a dynamic array, an associative array index and a fixed array of a string typedef
package p;
  typedef string str_t;
endpackage
module top;
  import p::*;
  str_t q[$];
  str_t d[];
  int m[str_t];
  str_t f[2];
  initial begin q.push_back("a"); d = new[1]; m["x"] = 1; f[0] = "b"; end
endmodule
