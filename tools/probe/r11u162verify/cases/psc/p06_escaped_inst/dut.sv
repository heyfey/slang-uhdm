// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic [CW-1:0] ci, output logic co); assign co = ^ci; endmodule
module top (input logic [7:0] in_i, output logic c_o);
  if (1) begin : \g$0
    child #(.CW(4)) \u$c (.ci(in_i[3:0]), .co(c_o));
  end
endmodule
