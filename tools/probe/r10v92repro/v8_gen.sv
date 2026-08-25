// v92 adversarial arm 8 — GENERATE homes and genvar conditions.
// The patch claims a structural fence: gen-scope cont_assigns never reach
// emitContAssigns.  Measure it three ways, plus a gen-for whose BODY holds a
// module instance whose OWN cont_assign folds (the fence must not leak).
module v8_leaf #(parameter bit EN = 1) (input logic [7:0] k, output logic [3:0] y);
  assign y = EN ? (k[5] ^ k[1]) : 4'h0;
endmodule

module v8_gen #(parameter bit EN = 1, parameter int N = 2) (
    input  logic [7:0] k,
    output logic [3:0] o
);
  logic [3:0] gy [0:1];
  logic [3:0] gi;
  logic [3:0] gb;
  logic [3:0] li [0:1];
  genvar gv;
  generate
    for (gv = 0; gv < 2; gv++) begin : gblk
      // a GENVAR condition inside gen-for
      assign gy[gv] = (gv == 0) ? (k[5] ^ k[1]) : 4'h0;
      // an instance inside gen-for whose own cont_assign folds
      v8_leaf #(.EN(EN)) u_l (.k(k), .y(li[gv]));
    end
    if (N > 1) begin : gif
      assign gi = EN ? (k[4] ^ k[1]) : 4'h0;
    end else begin : gelse
      assign gi = 4'h0;
    end
    begin : gnamed
      assign gb = EN ? (k[3] ^ k[1]) : 4'h0;
    end
  endgenerate
  assign o = gy[0] ^ gy[1] ^ gi ^ gb ^ li[0] ^ li[1];
endmodule
