// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic [CW-1:0] ci, output logic co); assign co = ^ci; endmodule
module top #(parameter int WIDTH = 8) (input logic [WIDTH-1:0] in_i, output logic c_o);
  child #(.CW(4)) u_c (.ci(in_i[3:0]), .co(c_o));
endmodule
