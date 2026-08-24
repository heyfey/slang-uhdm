// r10v81 arm v2 — HOMES AND OVERRIDE FORMS the implementer's g1/g2 never built:
// nested generate, an INTERFACE instance, a PROGRAM instance, an INSTANCE
// ARRAY, a POSITIONAL `#(2)` override and a `defparam` override.  Every cell is
// the same position (a port High_conn bit_select INDEX naming a module-scope
// parameter).  MEASUREMENT ONLY.
module leafv2 (input logic ib, output logic o);
  assign o = ib;
endmodule

interface ifcv2 #(parameter int unsigned IN = 1) (input logic sel);
  logic tap;
  assign tap = sel ^ IN[0];
endinterface

program progv2 #(parameter int unsigned PN = 1) (input logic sel);
  logic pv;
  initial pv = sel ^ PN[0];
endprogram

module midv2 #(
  parameter int unsigned N = 1,
  parameter int unsigned D = 1        // set by defparam at the parent
) (
  input  logic [15:0] w,
  output logic [15:0] y
);
  genvar gi, gj;
  leafv2 uPlain (.ib(w[N]), .o(y[0]));
  leafv2 uDef   (.ib(w[D]), .o(y[1]));
  // INSTANCE ARRAY of a leaf, actual carries the index
  leafv2 uArr [1:0] (.ib(w[N]), .o(y[3:2]));
  // NESTED GENERATE: for -> if -> for
  for (gi = 0; gi < 2; gi++) begin : go
    if (gi < 2) begin : gif
      for (gj = 0; gj < 2; gj++) begin : gin
        leafv2 uNest (.ib(w[N]), .o());
      end
    end
  end
  // an INTERFACE instance's port High_conn carrying the folded index
  ifcv2 #(.IN(2)) uIf (.sel(w[N]));
  // a PROGRAM instance's port High_conn carrying the folded index
  progv2 #(.PN(2)) uPr (.sel(w[N]));
endmodule

module midv2b #(parameter int unsigned N = 1)
               (input logic [15:0] w, output logic o);
  leafv2 uPos (.ib(w[N]), .o(o));
endmodule

module topv2 (input logic [15:0] w, output logic [15:0] y, output logic yp);
  midv2 #(.N(2)) i0 (.w(w), .y(y));
  defparam i0.D = 3;
  midv2b #(4) ipos (.w(w), .o(yp));       // POSITIONAL override
endmodule
