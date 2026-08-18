// v9 — MULTI-DIMENSIONAL interface arrays and 2-selector actuals.
interface sif;
  logic v;
  modport mp (input v);
endinterface
module ileaf (sif.mp s);
  wire w; assign w = s.v;
endmodule
module top;
  sif m2 [0:3][0:3] ();
  genvar i, j;
  for (i = 0; i < 2; ++i) begin : g
    for (j = 0; j < 2; ++j) begin : h
      ileaf a (.s (m2[i][j]));
      ileaf b (.s (m2[1+i][2-j]));
      ileaf c (.s (m2[i*2][j*2]));
    end
  end
endmodule
