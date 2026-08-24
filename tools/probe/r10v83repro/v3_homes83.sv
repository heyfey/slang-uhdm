// r10v83 arm 3 — THE HOME MATRIX.  The corpus shape `W83'(0)` as an ELABORATED
// port High_conn actual, from every HOME the verifier brief names and at 1, 2
// and 3 instances.  MEASUREMENT ONLY.
module snk3_83 (input logic [63:0] a, output logic [63:0] y);
  assign y = ~a;
endmodule

module snkn3_83 (input logic [11:0] a, output logic [11:0] y);
  assign y = ~a;
endmodule

interface if3_83 (input logic [63:0] a, output logic [63:0] y);
  assign y = a ^ 64'h7;
endinterface

module v3_homes83;
  localparam int W83 = 12;
  localparam int N83 = 3;
  logic [63:0] h0,h1,h2,h3,h4,h5,h6,h7,h8,h9,ha,hb;
  logic [11:0] arr1 [0:2];
  logic [63:0] acc;

  // H01 module scope, ONE instance
  snk3_83 h01 (.a(W83'(0)), .y(h0));
  // H02 module scope, an INSTANCE ARRAY of 3
  snkn3_83 h02 [2:0] (.a(W83'(1)), .y(arr1));
  // H03 gen-for, 3 iterations
  for (genvar gi = 0; gi < N83; gi++) begin : gfor3
    snk3_83 h03 (.a(W83'(2)), .y(h1));
  end
  // H04 gen-if TRUE arm
  if (N83 > 1) begin : gift
    snk3_83 h04 (.a(W83'(3)), .y(h2));
  end else begin : giff
    snk3_83 h04f (.a(W83'(4)), .y(h3));
  end
  // H05 NESTED gen: for inside if inside for
  for (genvar gj = 0; gj < 2; gj++) begin : gouter
    if (gj == 0) begin : gmid
      for (genvar gk = 0; gk < 2; gk++) begin : ginner
        snk3_83 h05 (.a(W83'(5)), .y(h4));
      end
    end
  end
  // H06 an INTERFACE instance with a port High_conn
  if3_83 h06 (.a(W83'(6)), .y(h5));
  // H07 module scope, THREE separate instances of the same module
  snk3_83 h07a (.a(W83'(7)), .y(h6));
  snk3_83 h07b (.a(W83'(8)), .y(h7));
  snk3_83 h07c (.a(W83'(9)), .y(h8));

  assign acc = h0^h1^h2^h3^h4^h5^h6^h7^h8^{52'd0,arr1[0]}^{52'd0,arr1[1]}^{52'd0,arr1[2]};
endmodule

program prg3_83;
  initial begin
  end
endprogram

module v3_top83;
  localparam int W83 = 8;
  logic [63:0] p0;
  v3_homes83 t0 ();
  snk3_83 t1 (.a(W83'(11)), .y(p0));
endmodule
