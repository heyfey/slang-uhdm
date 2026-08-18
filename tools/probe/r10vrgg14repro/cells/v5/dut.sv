// v5 — REVERSED and OFFSET interface/net array ranges: the slot->index map.
interface sif;
  logic v;
  modport mp (input v);
endinterface
module ileaf (sif.mp s);
  wire w; assign w = s.v;
endmodule
module nleaf (input logic p);
  wire w; assign w = p;
endmodule
module top (input logic [63:0] arr);
  sif dn  [63:0] ();     // descending
  sif up  [0:63] ();     // ascending
  sif off [10:20] ();    // ascending, offset
  sif rof [20:10] ();    // descending, offset
  genvar i;
  for (i = 0; i < 3; ++i) begin : g
    ileaf a (.s (dn [3+2*i]));
    ileaf b (.s (up [3+2*i]));
    ileaf c (.s (off[12+2*i]));
    ileaf d (.s (rof[12+2*i]));
    ileaf e (.s (dn [i]));
    ileaf f (.s (rof[20-i]));
    nleaf n (.p (arr[3+2*i]));
  end
endmodule
