// § classPropElemClassTsAtType183 (dynamic array, element typed through a typedef of a class, in a package)
package p;
class e; endclass
typedef e e_t;
class c;
  e_t lst[];
  e arr[3][2];
endclass
endpackage
module top; endmodule
