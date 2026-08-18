// r10v69 arm v5 - 1..3 INSTANCES of the same gen-scope body, with a parameter
// that differs per instance, so the same source text must render DIFFERENT
// folded names per instance in ELAB and the SOURCE text in DEF.
package pv5;
  parameter int WA = 7;
  parameter int WB = 8;
endpackage

typedef struct packed { logic [63:0] g; } rec5_t;

module body5 #(parameter int BP = 7, parameter int BW = 8) ();
  import pv5::*;
  localparam int BL = BP + 1;
  rec5_t arr [4];
  logic [7:0] o [32];
  logic       ob [32];
  for (genvar i = 0; i < 2; i++) begin : g5
    assign o[0]  = arr[i].g[BP+:BW];      // instance parameter bounds
    assign o[1]  = arr[i].g[BL+:BW];      // localparam derived from parameter
    assign o[2]  = arr[i].g[WA+:WB];      // package params (same every instance)
    assign ob[0] = arr[i].g[BP];
    assign o[3]  = arr[i].g[BP+i+:BW];
  end
  assign o[8] = arr[0].g[BP+:BW];
endmodule

module v5 ();
  body5 #(.BP(7),  .BW(8)) u0 ();
  body5 #(.BP(11), .BW(4)) u1 ();
  body5 #(.BP(3),  .BW(2)) u2 ();
endmodule
