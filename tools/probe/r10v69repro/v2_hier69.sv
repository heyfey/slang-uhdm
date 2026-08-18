// r10v69 arm v2 - HIERARCHICAL refs: instance arrays and interface arrays,
// read from inside and outside gen scopes.
package pv2;
  parameter int QA = 3;
  parameter int QB = 4;
endpackage

interface if2 ();
  logic [31:0] bus;
  logic [31:0] alt;
endinterface

module leaf2 ();
  logic [31:0] sig;
  logic [31:0] sig2;
endmodule

module v2 import pv2::*; ();
  localparam int MA = 3;
  logic [7:0] o [64];
  logic       ob [64];

  if2 ifa [4] ();
  leaf2 la [4] ();

  for (genvar i = 0; i < 3; i++) begin : gv2
    // interface array element, param ips bound
    assign o[0] = ifa[i].bus[QA+:QB];
    // interface array with a PARAM index
    assign o[1] = ifa[QA].alt[QA+:QB];
    // instance array hierarchical read, param bounds
    assign o[2] = la[i].sig[QA+:QB];
    // instance array with a PARAM index
    assign o[3] = la[QA].sig2[MA+:QB];
    // bit-select with param index through an instance array
    assign ob[0] = la[i].sig[QA];
    // no trailing select
    assign o[4] = la[i].sig2[7:0];
  end

  // gen-block hierarchical reference into a generate scope
  for (genvar j = 0; j < 3; j++) begin : gblk
    logic [31:0] w;
    assign w = 32'd0;
  end
  assign o[10] = gblk[0].w[QA+:QB];
  assign o[11] = gblk[QA-3].w[MA+:QB];

  // module-body copies
  assign o[12] = ifa[0].bus[QA+:QB];
  assign o[13] = la[0].sig[QA+:QB];
  assign ob[8] = la[1].sig[QA];
endmodule
