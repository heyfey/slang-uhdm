// § aliasCloneTakesTargetFile137
// case al05: a package alias used by two modules
package ap5;
  typedef struct packed { logic k; } a;
  typedef a b[3:0];
endpackage
module m1(); ap5::b v1; endmodule
module top(); ap5::b v2; m1 u(); endmodule
