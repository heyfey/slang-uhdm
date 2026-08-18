// v12 — a bare genvar-only index in EVERY position at once, with the loop NOT
// starting at 0 and stepping by more than 1 (the slot<->value map again).
interface sif;
  logic [7:0] v;
  modport mp (input v);
endinterface
module ileaf (sif.mp s);
  wire w; assign w = s.v[0];
endmodule
module nleaf (input logic p);
  wire w; assign w = p;
endmodule
module top (input logic [63:0] arr, output logic [63:0] o);
  sif sarr [0:63] ();
  genvar i;
  for (i = 3; i < 12; i = i + 4) begin : g
    ileaf a (.s (sarr[i]));
    ileaf b (.s (sarr[i+1]));
    ileaf c (.s (sarr[2*i]));
    nleaf d (.p (arr[i]));
    nleaf e (.p (arr[2*i-5]));
    assign o[i] = arr[i+1] ^ sarr[i].v[0];
  end
endmodule
