// § elabCloneFullNameUnstored137
module dut(input logic a, output logic b);
  task automatic t(input logic v, output logic w);
    logic z;
    z = v;
    w = z;
  endtask
  always_comb begin : blk
    logic loc;
    t(a, loc);
    b = loc;
  end
endmodule
module top(input logic x, output logic y);
  dut u(.a(x), .b(y));
endmodule
