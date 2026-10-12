// § incDecIpsWholeSpan288 — a parameter width, a for-loop step, a nested index (stays an rvalue), a member path, an expression position, a task and a for-generate process
module top #(parameter int W = 2)(input logic clk, input logic [2:0] k, output logic [15:0] q, r);
  typedef struct packed { logic [7:0] f; } s_t;
  s_t sv;
  logic [3:0] idx [4];
  logic [7:0] y;
  task automatic t(); q[k +: W]--; endtask
  always_ff @(posedge clk) begin
    q[k +: W]++;
    for (int i = 0; i < 2; r[i +: 2]++) i++;
    r[idx[k][1 +: 2]]++;
    sv.f[k +: 2]++;
    y = q[k -: 2]++;
    t();
  end
  for (genvar g = 0; g < 2; g++) begin : gb
    logic [7:0] v;
    always_comb begin v = '0; v[g +: 2]++; end
  end
endmodule
