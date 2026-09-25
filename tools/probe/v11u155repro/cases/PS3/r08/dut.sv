// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic [CW-1:0] ci, output logic co); assign co = ^ci; endmodule
module top #(parameter int WIDTH = 8) (input logic [WIDTH-1:0] in_i, output logic [1:0] c_o);
  if (WIDTH > 1) begin : gen_inst
    child #(.CW(4)) u_c [1:0] (.ci(in_i[7:0]), .co(c_o));
  end
endmodule
