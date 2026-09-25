// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic [CW-1:0] ci, output logic co); assign co = ^ci; endmodule
module top #(parameter int WIDTH = 8) (input logic [WIDTH-1:0] in_i, output logic c_o, output logic d_o);
  if (WIDTH > 1) begin : gen_inst
    child #(.CW(4)) u_c (.ci(in_i[3:0]), .co(c_o));
  end
  child #(.CW(4)) u_d (.ci(in_i[7:4]), .co(d_o));
endmodule
