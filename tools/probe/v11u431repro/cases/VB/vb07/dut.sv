// § unitParamNameBindsDesign431 (a task reading the module's shadowing localparam)
localparam CF = 2;
module top(input [3:0] c, output logic y);
localparam CF = 1;
task automatic t(output logic o);
  o = c[CF];
endtask
always_comb t(y);
endmodule
