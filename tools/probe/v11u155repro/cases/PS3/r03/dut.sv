// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic [CW-1:0] ci, output logic co); assign co = ^ci; endmodule
module top #(parameter int WIDTH = 8) (input logic [WIDTH-1:0] in_i, output logic [1:0] c_o);
  localparam int HI = 3;
  if (WIDTH > 1) begin : gen_inst
    for (genvar k = 0; k < 2; k++) begin : gl
      child #(.CW(HI+1)) u_c (.ci(in_i[HI:0]), .co(c_o[k]));
    end
  end
endmodule
