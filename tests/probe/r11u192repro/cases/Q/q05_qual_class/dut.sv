// § pkgQualBoundSpanQualifier192
package q;
  parameter int unsigned S = $clog2(16);
endpackage
package p;
  class C;
    function logic [31:0] g(input logic [31:0] a);
      return a[q::S:0];
    endfunction
  endclass
endpackage
module top (input logic [31:0] x, output logic [31:0] y2);
  initial begin
    p::C c;
    c = new;
    y2 = c.g(x);
  end
endmodule
