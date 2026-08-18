// v3 — HOMES: nested gen-for, gen-if inside gen-for, interface gen-for,
// case-generate, a gen-for at module top level and inside an interface.
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
interface ihost #(parameter int N = 2) (input logic [63:0] arr);
  sif iarr [0:15] ();
  genvar gi;
  for (gi = 0; gi < 2; ++gi) begin : gg
    wire wx = iarr[2+3*gi].v;
    wire wy = arr[2+3*gi];
  end
endinterface
module top #(parameter int MODE = 1) (input logic [63:0] arr);
  sif sarr [0:63] ();
  genvar i, j, k;
  ihost hh (.arr(arr));
  for (i = 0; i < 2; ++i) begin : g1
    if (i == 0) begin : gi0
      ileaf p0 (.s (sarr[4+2*i]));
      nleaf q0 (.p (arr[4+2*i]));
    end
    else begin : gi1
      ileaf p1 (.s (sarr[9+2*i]));
      nleaf q1 (.p (arr[9+2*i]));
    end
    case (MODE)
      1: begin : gc1
        ileaf p2 (.s (sarr[20+2*i]));
        nleaf q2 (.p (arr[20+2*i]));
      end
      default: begin : gcd
        ileaf p3 (.s (sarr[30+2*i]));
      end
    endcase
    for (j = 0; j < 2; ++j) begin : g2
      for (k = 0; k < 2; ++k) begin : g3
        ileaf p4 (.s (sarr[1+8*i+4*j+k]));
        nleaf q4 (.p (arr[1+8*i+4*j+k]));
      end
    end
  end
endmodule
