// § unitParamNameBindsDesign431 (an immediate assertion and a system call argument)
localparam CF = 2;
module top(input [3:0] c, output logic y);
localparam CF = 1;
always_comb begin
  y = c[0];
  assert (c[CF] == 1'b0);
  $display("%d", CF);
end
endmodule
