// § pselConnNameNotFrozen155
module child #(parameter int CW = 2) (input logic [CW-1:0] ci, output logic co); assign co = ^ci; endmodule
module top (input logic [15:0] in_i, output logic [3:0] c_o);
  for (genvar a = 0; a < 2; a++) begin : ga
    for (genvar b = 0; b < 2; b++) begin : gb
      child #(.CW(4)) u_c (.ci(in_i[(a*2+b)*4+3:(a*2+b)*4]), .co(c_o[a*2+b]));
    end
  end
endmodule
