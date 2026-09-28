// § classPropElemQualTs186 § classPropElemClassTsAtType183: package-qualified element classes in a queue, a fixed array and a string-keyed associative array of a package class
package q;
  class e; endclass
endpackage
package p;
  class c;
    q::e lst[$];
    q::e arr[4];
    q::e m[string];
  endclass
endpackage
module top; endmodule
