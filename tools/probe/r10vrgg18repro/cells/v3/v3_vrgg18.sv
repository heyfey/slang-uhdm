// r10vrgg18 grid V3 — HOMES: gen-if (both arms), nested gen-for, an
// interface-homed generate, and a module-scope control twin of each row.
interface v3_if;
  genvar gi;
  generate
    for (gi = 0; gi < 2; gi++) begin : gif
      localparam bit [6:0] IU = 7'h40 + 7'(gi);
      localparam bit [7:0] IV = 8'hC0 + 8'(gi);
    end
  endgenerate
endinterface

module v3_vrgg18;
  parameter int NN = 2;
  localparam bit [6:0] MGI = 7'h40 + 7'd0;   // module-scope control
  genvar g, h;
  generate
    if (NN == 2) begin : gif_true
      localparam bit [6:0] GI = 7'h40 + 7'd0;
      for (g = 0; g < 2; g++) begin : inner
        localparam bit [6:0] NEST = 7'h40 + 7'(g);
        for (h = 0; h < 2; h++) begin : inner2
          localparam bit [7:0] DEEP = 8'hC0 + 8'(g) + 8'(h);
        end
      end
    end
    else begin : gif_false
      localparam bit [6:0] GF = 7'h7F;
    end
  endgenerate
  v3_if u_if();
endmodule
