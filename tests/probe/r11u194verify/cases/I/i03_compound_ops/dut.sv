// § incDecMemberSelIsLvalue184 (controls): compound assignments on member selects (+=, -=, <<=) beside ++ in a task and a generate-scope process
module top (input logic clk, input logic [1:0] k, output logic [7:0] o);
  typedef struct packed { logic [3:0][7:0] f; } s_t;
  s_t s;
  task automatic upd(input logic [1:0] j);
    s.f[j] += 2;
    s.f[j] -= 1;
    s.f[j + 1] <<= 1;
    s.f[j]++;
  endtask
  if (1) begin : g
    s_t t;
    always @(posedge clk) begin
      t.f[k] += 3;
      t.f[k]++;
    end
  end
  always @(posedge clk) upd(k);
  assign o = s.f[0];
endmodule
