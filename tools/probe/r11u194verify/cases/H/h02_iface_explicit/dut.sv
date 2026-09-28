// § importNetTsToInitEnd183: explicit imports of package variables with initializers into an interface and a module, one single-line and one spanning three lines; a class handle with an initializer excluded
package p;
  class c; endclass
  int single = 5;
  bit [15:0] tri_line = 16'h1 |
                        16'h2 |
                        16'h4;
  c h = null;
endpackage
interface bi;
  import p::tri_line;
  logic [15:0] v;
  assign v = tri_line;
endinterface
module top (output int o);
  import p::single;
  import p::h;
  bi b ();
  assign o = single;
endmodule
