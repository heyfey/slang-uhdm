// § classPropElemQualTs186 (a qualified element in an associative and a fixed array, blanks around the colons)
package q;
class e; endclass
endpackage
package p;
class c;
  q::e by_key[int];
  q :: e fixed_a[2];
endclass
endpackage
module top; endmodule
