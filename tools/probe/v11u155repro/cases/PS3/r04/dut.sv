// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic [CW-1:0] ci, output logic co); assign co = ^ci; endmodule
module top #(parameter int WIDTH = 8) (input logic [WIDTH-1:0] in_i, output logic c_o);
  localparam int HI = 5;
  if (WIDTH > 1) begin : gen_inst
    child #(.CW(HI-1)) u_c (.ci(in_i[HI:2]), .co(c_o));
  end
endmodule
