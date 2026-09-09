// v226 b04 — GENERATE-SCOPED and nested processes inside an uninstantiated
// interface: a bare generate region, a genvar for-loop, an if-generate taken
// and untaken, and a case-generate.  The def view lists what?
interface bg_if;
  parameter int N = 2;
  logic [3:0] v;
  int         own;
  initial own = 0;                 // the interface's OWN process

  generate
    always_comb v[0] = 1'b0;       // bare generate region
  endgenerate

  for (genvar g = 0; g < N; g++) begin : lp
    always_comb v[g+1] = 1'b1;
  end

  if (N == 2) begin : taken
    initial own = 1;
  end else begin : untaken
    initial own = 2;
  end

  case (N)
    2: begin : c2  always_comb v[3] = 1'b0; end
    default: begin : cd always_comb v[3] = 1'b1; end
  endcase
endinterface

// The same body under a module, for the holder split.
module bg_mod;
  parameter int N = 2;
  logic [3:0] v;
  int         own;
  initial own = 0;
  generate
    always_comb v[0] = 1'b0;
  endgenerate
  for (genvar g = 0; g < N; g++) begin : lp
    always_comb v[g+1] = 1'b1;
  end
endmodule
