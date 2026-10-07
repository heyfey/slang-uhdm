// § tfLocalArrRangeDimEnd275 — a module task with a ranged static local
module dut (input logic clk, output int o);
  task automatic t(output int r);
    logic [7:0] v [0:2];
    v[0] = 8'h3;
    r = v[0];
  endtask
  always_ff @(posedge clk) t(o);
endmodule
