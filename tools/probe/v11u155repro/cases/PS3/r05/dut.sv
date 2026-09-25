// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic [CW-1:0] ci, output logic co); assign co = ^ci; endmodule
module mid #(parameter int WIDTH = 8) (input logic [WIDTH-1:0] in_i, output logic c_o);
  if (WIDTH > 1) begin : gen_inst
    child #(.CW(4)) u_c (.ci(in_i[3:0]), .co(c_o));
  end
endmodule
module top (input logic [7:0] a, output logic y);
  mid #(.WIDTH(8)) m (.in_i(a), .c_o(y));
endmodule
