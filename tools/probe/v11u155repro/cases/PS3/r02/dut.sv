// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic [CW-1:0] ci, output logic co); assign co = ^ci; endmodule
module top #(parameter int WIDTH = 8) (input logic [WIDTH-1:0] in_i, output logic c_o);
  case (WIDTH)
    8: begin : gc
      child #(.CW(4)) u_c (.ci(in_i[7:4]), .co(c_o));
    end
    default: begin : gd
      assign c_o = 0;
    end
  endcase
endmodule
