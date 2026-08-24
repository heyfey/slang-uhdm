// r10v122 arm q6 - the IMPORT-CLONE fence: a home package, a WILDCARD
// importing package, an EXPLICIT importing package, and an importing module.
package HomeMu_pkg;
  function automatic int unsigned mixMu(int unsigned inMu);
    bit [31:0] accMu;
    accMu = inMu;
    if (inMu != 0) begin
      accMu ^= 32'hDEAD_0001;
      accMu[0] = 1'b1;
    end
    mixMu = accMu;
  endfunction
  task automatic stirMu(input int unsigned tIn, output int unsigned tOut);
    bit [15:0] tmpMu;
    tmpMu = 16'(tIn);
    if (tIn != 1) begin
      tmpMu |= 16'h20;
      tmpMu[4:2] = 3'b101;
    end
    tOut = 32'(tmpMu);
  endtask
endpackage

package WildNu_pkg;
  import HomeMu_pkg::*;
  function automatic int unsigned useWild(int unsigned wIn);
    useWild = mixMu(wIn);
  endfunction
endpackage

package ExplXi_pkg;
  import HomeMu_pkg::mixMu;
  function automatic int unsigned useExpl(int unsigned xIn);
    useExpl = mixMu(xIn + 32'd1);
  endfunction
endpackage

module ImpOmicron (input logic [7:0] pIn, output logic [7:0] pOut);
  import HomeMu_pkg::*;
  logic [7:0] rMu;
  always_comb begin
    rMu = 8'(mixMu(32'(pIn)));
  end
  assign pOut = rMu;
endmodule
