// § pkgTsForeignQualRefUnstored144
package p;
  parameter int W = 4;
endpackage
package q;
  function automatic logic [p::W-1:0] f(input logic [p::W-1:0] a);
    return a;
  endfunction
endpackage
module dut(input logic [3:0] a, output logic [3:0] o);
  assign o = q::f(a);
endmodule
