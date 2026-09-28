// § classImportParamOwnRefs183: a package with a parameter, a localparam of string, a bit-vector parameter and a real parameter imported by a package declaring two classes (one derived), and by a module
package u;
  parameter int W = 8;
  localparam string S = "tag";
  parameter bit [3:0] B = 4'hA;
  class base; endclass
endpackage
package s;
  import u::*;
  class d1 extends base;
    int x = W;
  endclass
  class d2;
    string n = S;
  endclass
endpackage
module top;
  import u::*;
  logic [W-1:0] v;
endmodule
