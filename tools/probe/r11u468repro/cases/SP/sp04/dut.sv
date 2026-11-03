// § specArgPairsImportedFormal468
// control: no import, the formal keeps its own name
package p;
  parameter int PB = 3;
  parameter int PA = 2;
  int v;
endpackage
class item; int d; endclass
class C #(type T = int);
  T m;
endclass
module top;
  C #(item) h;
endmodule
