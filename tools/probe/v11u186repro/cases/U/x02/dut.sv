// § classPropElemQualTs186 (a class in a module, qualified element; a $unit-qualified element)
package q;
class f; endclass
endpackage
class g; endclass
module top;
  class c;
    q::f lst[$];
    $unit::g m[$];
  endclass
endmodule
