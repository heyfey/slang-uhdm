// § aliasCloneTakesTargetFile137
// case al03: an alias chain over a package struct typedef
package cp2;
  typedef struct packed { logic k; } a;
  typedef a b[2];
  typedef b c[3];
endpackage
module top();
  cp2::c v;
endmodule
