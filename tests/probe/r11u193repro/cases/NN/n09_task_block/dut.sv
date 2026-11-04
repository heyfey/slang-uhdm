// § nestedDefChainName193
module sub ();
  module innermod (input logic c, output logic [3:0] r);
    task automatic t(output logic [3:0] y);
      y = 4'd7;
    endtask
    always_comb begin : blk
      logic [3:0] z;
      t(z);
      r = c ? z : 4'd0;
    end
  endmodule
endmodule
module dut (output logic [3:0] o);
  sub u_s ();
  assign o = 4'd0;
endmodule
