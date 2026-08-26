// p4 — does an INITIAL / ALWAYS block behave the same in a MODULE, a PROGRAM
// and an INTERFACE?  Every typedef name is unique in the design.
module mInit155v;
  initial begin
    typedef byte tdModInit155v;
    tdModInit155v vModInit155v;
    vModInit155v = 8'd1;
  end
  always_comb begin
    typedef byte tdModAlways155v;
    tdModAlways155v vModAlways155v;
    vModAlways155v = 8'd2;
  end
  final begin
    typedef byte tdModFinal155v;
    tdModFinal155v vModFinal155v;
    vModFinal155v = 8'd3;
  end
  task automatic tMod155v();
    typedef byte tdModTask155v;
    tdModTask155v vModTask155v;
    vModTask155v = 8'd4;
  endtask
endmodule

program prgInit155v;
  initial begin
    typedef byte tdPrgInit155v;
    tdPrgInit155v vPrgInit155v;
    vPrgInit155v = 8'd5;
  end
  final begin
    typedef byte tdPrgFinal155v;
    tdPrgFinal155v vPrgFinal155v;
    vPrgFinal155v = 8'd6;
  end
  task automatic tPrg155v();
    typedef byte tdPrgTask155v;
    tdPrgTask155v vPrgTask155v;
    vPrgTask155v = 8'd7;
  endtask
endprogram

interface ifcInit155v;
  initial begin
    typedef byte tdIfcInit155v;
    tdIfcInit155v vIfcInit155v;
    vIfcInit155v = 8'd8;
  end
  task automatic tIfc155v();
    typedef byte tdIfcTask155v;
    tdIfcTask155v vIfcTask155v;
    vIfcTask155v = 8'd9;
  endtask
endinterface

package pkgInit155v;
  function automatic int fPkg155v();
    typedef byte tdPkgFunc155v;
    tdPkgFunc155v vPkgFunc155v;
    vPkgFunc155v = 8'd10;
    return int'(vPkgFunc155v);
  endfunction
endpackage

module mTop155v;
  ifcInit155v ii155v();
endmodule
