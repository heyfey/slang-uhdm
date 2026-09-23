package pk; parameter int unsigned P = 5; endpackage
module top import pk::*; (input logic [7:0] i, output logic [7:0] o);
  task automatic t(output logic [7:0] r);
    logic [P:0] v;
    v = '1;
    r = v;
  endtask
  always_comb t(o);
endmodule
