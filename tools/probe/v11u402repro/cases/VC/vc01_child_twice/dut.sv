// § moduleNamedClocking402
module child(input clk, input d, output logic q);
  clocking cb @(posedge clk);
    input d;
    output q;
  endclocking
endmodule
module top(input clk, d, output q1, q2);
  child u1(.clk(clk), .d(d), .q(q1));
  child u2(.clk(clk), .d(d), .q(q2));
endmodule
