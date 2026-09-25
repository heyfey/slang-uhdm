// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic [CW-1:0] ci, output logic co); assign co = ^ci; endmodule
module top (input logic [7:0] in_i, output logic [3:0] c_o);
  for (genvar k = 0; k < 4; k++) begin : gl
    child #(.CW(2)) u_c (.ci(in_i[k*2 +: 2]), .co(c_o[k]));
  end
endmodule
