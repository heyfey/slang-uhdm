// § clsPropSpecPaNoFile243
// a generic in an included header, used by holders in two files' worth of text
package p;
  `include "gen.svh"
  class h1;
    gen #(int) a;
  endclass
endpackage
class h2;
  p::gen #(logic) b;
endclass
module top;
  p::h1 x;
  h2 y;
endmodule
