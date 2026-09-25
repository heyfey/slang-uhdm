// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic [CW-1:0] ci, output logic co); assign co = ^ci; endmodule
module top #(parameter int WIDTH = 8) (input logic [WIDTH-1:0] in_i, output logic c_o);
  if (WIDTH > 1) begin : gen_inst
    child #(4) u_c (in_i[5:2], c_o);
  end
endmodule
