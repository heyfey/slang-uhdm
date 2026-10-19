// § unitTaskNotListed408
task automatic ut(output logic [3:0] o);
  o = 4'd3;
endtask
module top(output logic [3:0] y);
  always_comb ut(y);
endmodule
