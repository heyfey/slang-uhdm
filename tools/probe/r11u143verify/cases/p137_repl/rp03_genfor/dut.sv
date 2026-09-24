// § connReplTsRefThroughPort137
// case rp03: a constant replication actual on an instance inside a generate for
module sub(input logic [5:0] m, output logic [5:0] o); assign o = m; endmodule
module top(output logic [11:0] o);
  for (genvar g = 0; g < 2; g++) begin : gl
    sub u(.m({3{2'b10}}), .o(o[g*6 +: 6]));
  end
endmodule
