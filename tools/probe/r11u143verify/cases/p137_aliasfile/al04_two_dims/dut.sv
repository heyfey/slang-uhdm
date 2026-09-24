// § aliasCloneTakesTargetFile137
// case al04: an alias with two unpacked dimensions over a package struct
package ap4;
  typedef struct packed { logic k; logic m; } a;
  typedef a b[1:0][2:0];
endpackage
module top();
  ap4::b v;
endmodule
