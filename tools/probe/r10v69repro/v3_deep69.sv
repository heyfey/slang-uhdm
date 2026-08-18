// r10v69 arm v3 - nested genvars (3 deep), mixed P+i, part-selects, and the
// same texts in a DEF-only (uninstantiated) module.
package pv3;
  parameter int RA = 7;
  parameter int RB = 8;
endpackage

typedef struct packed { logic [63:0] m; } rec3_t;

module v3 import pv3::*; ();
  localparam int SA = 7;
  localparam int SB = 8;
  rec3_t arr [4];
  rec3_t marr [4][4][4];
  logic [7:0] o [64];
  logic       ob [64];

  for (genvar i = 0; i < 2; i++) begin : g3a
    for (genvar j = 0; j < 2; j++) begin : g3b
      for (genvar k = 0; k < 2; k++) begin : g3c
        assign o[0]  = arr[i].m[RA+:RB];
        assign o[1]  = marr[i][j][k].m[RA+:RB];
        assign o[2]  = marr[i][j][k].m[SA+:SB];
        assign o[3]  = arr[i].m[RA+j+:RB];
        assign o[4]  = arr[i].m[j+:RB];
        assign o[5]  = arr[i].m[RB:RA];
        assign ob[0] = arr[i].m[RA];
        assign ob[1] = arr[i].m[k];
        assign o[6]  = marr[RA-7][j][i].m[RA+:RB];
      end
    end
  end

  assign o[10] = arr[0].m[RA+:RB];
  assign o[11] = marr[0][1][2].m[SA+:SB];
endmodule

// A module NEVER instantiated - DEF view only.
module v3def import pv3::*; ();
  localparam int TA = 7;
  rec3_t darr [4];
  logic [7:0] o [8];
  for (genvar i = 0; i < 2; i++) begin : g3d
    assign o[0] = darr[i].m[RA+:RB];
    assign o[1] = darr[i].m[TA+:RB];
  end
  assign o[2] = darr[0].m[RA+:RB];
endmodule
