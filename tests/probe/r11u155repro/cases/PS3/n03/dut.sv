// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic [CW-1:0] ci, output logic co); assign co = ^ci; endmodule
module top #(parameter int WIDTH = 8) (input logic [WIDTH-1:0] in_i, output logic [1:0] c_o);
  for (genvar k = 0; k < 2; k++) begin : gl
    child #(.CW(4)) u_c (.ci(in_i[4*k+3:4*k]), .co(c_o[k]));
  end
endmodule
