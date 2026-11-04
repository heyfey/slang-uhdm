// § derivedClassFullNameOrder422
// a base in package mm; derived classes in packages zz and aa, $unit and a module
package mm;
  class B; endclass
endpackage
package zz;
  class K extends mm::B; endclass
endpackage
package aa;
  class L extends mm::B; endclass
endpackage
class M extends mm::B; endclass
module top;
  class T extends mm::B; endclass
  zz::K k = new; aa::L l = new; M m = new; T t = new;
endmodule
