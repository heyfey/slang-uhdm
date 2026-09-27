// § classPropElemQualTs186 (a parameterized qualified element class, an assoc array, a fixed array)
package q;
class e #(int N = 1); endclass
class f; endclass
endpackage
package p;
class c;
  q::e#(8) lst[$];
  q::f m[string];
  q :: f n[2];
endclass
endpackage
module top; endmodule
