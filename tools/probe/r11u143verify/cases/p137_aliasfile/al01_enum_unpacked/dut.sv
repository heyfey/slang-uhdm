// § aliasCloneTakesTargetFile137
// case al01: an unpacked-array alias of an enum typedef in a package
package ap;
  typedef enum logic [1:0] {Q0, Q1} e_t;
  typedef e_t ea[3];
endpackage
module top();
  ap::ea v;
endmodule
