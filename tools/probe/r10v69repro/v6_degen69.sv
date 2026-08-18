// r10v69 arm v6 - DEGENERATE and bracket-PRESENCE shapes: queues, dynamic and
// associative arrays, unpacked+packed mixes, a select whose base is a
// hier_path, and reads that produce EMPTY bracket groups.
package pv6;
  parameter int YA = 2;
  parameter int YB = 3;
endpackage

typedef struct packed { logic [31:0] h; logic [31:0] k; } rec6_t;

module v6 import pv6::*; ();
  localparam int ZA = 2;
  rec6_t arr [4];
  rec6_t parr [4][4];
  logic [3:0][7:0] packarr [4];
  logic [7:0] o [64];
  logic       ob [64];

  for (genvar i = 0; i < 2; i++) begin : g6
    // packed-array dimension inside a member read
    assign o[0]  = packarr[i][YA];
    assign o[1]  = packarr[YA][ZA];
    // two unpacked dims then a member then an ips
    assign o[2]  = parr[i][YA].h[YA+:YB];
    assign o[3]  = parr[YA][ZA].k[ZA+:YB];
    // whole struct read (no select at all)
    assign o[4]  = arr[i].h;
    // ips whose base is another select's result
    assign o[5]  = arr[i].h[arr[i].k[1:0]+:YB];
    // reversed range with param bounds
    assign o[6]  = arr[i].h[YB:YA];
    // descending indexed part select
    assign o[7]  = arr[i].h[YB-:YA];
  end

  assign o[16] = parr[0][YA].h[YA+:YB];
  assign o[17] = arr[0].h[YB-:YA];
endmodule
