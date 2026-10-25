// § unitParamShadowDefBind432
localparam CF = 0;
module m(input clk, input [3:0] a, output logic o);
  localparam CF = 1;
  task t(output logic r);
    r = a[CF];
  endtask
  always @(posedge clk) t(o);
endmodule
