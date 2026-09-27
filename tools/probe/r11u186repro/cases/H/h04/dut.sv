// § importNetTsToInitEnd183 (interface importer)
package p;
  bit [3:0] seed = 4'b1010;
endpackage
interface itf;
  import p::*;
  logic [3:0] v;
  assign v = seed;
endinterface
module top;
  itf i();
endmodule
