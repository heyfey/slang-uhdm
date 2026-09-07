// r10uvm200 grid arm A — WHERE the late-bound reference lives inside a
// wildcard-import CLONE of a package subroutine.  One real Surelog golden.
package pa200a;
  parameter WA = 4*2-1;
  function logic [WA:0] fa(input logic [WA:0] x);
    logic [WA:0] loc1;
    begin : nb
      logic [WA:0] loc2;
      loc1 = x;
      loc2 = loc1;
      fa = loc2;
    end
  endfunction
  task ta(input logic [WA:0] y, output logic [7:0] z);
    z = 8'h0;
  endtask
  function int fb(input int k = WA);
    fb = k + WA;
  endfunction
  function logic [7:0] flit(input logic [7:0] w);
    flit = w;
  endfunction
endpackage

package pb200a;
  import pa200a::*;
endpackage

module top200a;
  import pa200a::*;
  initial $display(WA);
endmodule
