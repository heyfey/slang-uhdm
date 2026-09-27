// § classPropElemQualTs186 (the qualified element written through a macro; a nested-class qualifier abstains)
`define ET q::e
package q;
class e; endclass
class o; class n; endclass endclass
endpackage
package p;
class c;
  `ET lst[$];
  q::o::n m[$];
endclass
endpackage
module top; endmodule
