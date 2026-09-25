// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic ci, output logic [CW-1:0] co); assign co = {CW{ci}}; endmodule
module top (input logic in_i, output logic [7:0] c_o);
  if (1) begin : g
    child #(.CW(4)) u_c (.ci(in_i), .co(c_o[7:4]));
  end
  assign c_o[3:0] = '0;
endmodule
