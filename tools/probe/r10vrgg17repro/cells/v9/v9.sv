// vrgg17 v9 — a path with TWO array components (the running-fullname axis) and
// a deep 4-component path.
interface sif; logic [31:0] value; endinterface
module holder;
  sif s[4]();
endmodule
module sink (input logic [3:0] d); endmodule
module top;
  holder h[4]();
  for (genvar i = 0; i < 2; i++) begin : g
    for (genvar j = 0; j < 2; j++) begin : gj
      sink u_d1 (.d(h[1+2*i].s[1+2*j].value[0+:4]));  // BOTH components fold
      sink u_d2 (.d(h[1+2*i].s[2].value[0+:4]));      // first folds, second literal
      sink u_d3 (.d(h[2].s[1+2*j].value[0+:4]));      // second folds only
    end
  end
endmodule
