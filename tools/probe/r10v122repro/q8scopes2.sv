// r10v122 arm q8 - homes the earlier arms did not reach: an interface task, a
// program block, a generate block, an explicit `var`, a static/virtual method,
// a nested class, and a $unit-scope function.
function automatic int unitFnY(int y0);
  bit [11:0] uvY;
  uvY = 12'h1;
  if (y0 != 0) begin
    uvY ^= 12'h2;
    uvY[3] = 1'b1;
  end
  unitFnY = int'(uvY);
endfunction

interface IfaceAlpha (input logic clkI);
  logic [7:0] ifVec;
  task automatic ifTask(input int t0, output int t1);
    bit [7:0] ifLoc;
    ifLoc = 8'h1;
    if (t0 != 0) begin
      ifLoc ^= 8'h2;
      ifLoc[3] = 1'b1;
    end
    t1 = int'(ifLoc);
  endtask
  always_comb begin
    ifVec = 8'h0;
    if (clkI) begin
      ifVec ^= 8'h4;
      ifVec[5] = 1'b1;
    end
  end
endinterface

program ProgBeta (input logic pClk);
  int pRes;
  initial begin
    bit [7:0] pLoc;
    pLoc = 8'h1;
    if (pClk) begin
      pLoc |= 8'h6;
      pLoc[7:6] = 2'b10;
    end
    pRes = int'(pLoc);
  end
endprogram

package Gamma5_pkg;
  class BaseGam;
    virtual function int vFn(int v0);
      bit [9:0] vLoc;
      vLoc = 10'h1;
      if (v0 != 0) begin
        vLoc ^= 10'h2;
        vLoc[4] = 1'b1;
      end
      vFn = int'(vLoc);
    endfunction
    static function int sFn(int s0);
      bit [9:0] sLoc;
      sLoc = 10'h3;
      if (s0 != 1) begin
        sLoc |= 10'h4;
        sLoc[6:5] = 2'b11;
      end
      sFn = int'(sLoc);
    endfunction
  endclass
  class InnerGam extends BaseGam;
    function int iFn(int i0);
      bit [9:0] iLoc;
      iLoc = 10'h5;
      if (i0 != 2) begin
        iLoc &= 10'h6;
        iLoc[8] = 1'b0;
      end
      iFn = int'(iLoc);
    endfunction
  endclass
endpackage

module GenDelta #(parameter int NREP = 2) (input logic gClk, output logic [7:0] gOut);
  var logic [7:0] gVarVec;
  logic [7:0] gAcc [0:NREP-1];
  genvar gi;
  generate
    for (gi = 0; gi < NREP; gi++) begin : gblk
      always_comb begin
        bit [7:0] gLoc;
        gLoc = 8'(gi);
        if (gClk) begin
          gLoc ^= 8'h9;
          gLoc[2] = 1'b1;
        end
        gAcc[gi] = gLoc;
      end
    end
  endgenerate
  always_comb begin
    gVarVec = gAcc[0];
    if (gClk) begin
      gVarVec ^= 8'hA;
      gVarVec[1] = 1'b1;
    end
  end
  assign gOut = gVarVec ^ 8'(unitFnY(1));
endmodule
