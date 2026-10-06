// § genIfacePortActualInst263
interface bif #(parameter int AW = 16, parameter int BW = 32);
  logic valid;
  logic [AW-1:0] addr;
  modport master(output valid, output addr);
endinterface
module ext(bif.master bus_if);
  assign bus_if.valid = 1'b1;
endmodule
module chk(input logic v);
endmodule
module blk(bif.master b15);
  if (1) begin : g
    ext u(.bus_if(b15));
  end
endmodule
bind blk chk u_chk(.v(b15.valid));
module top;
  bif #(8, 32) b();
  blk u_blk(.b15(b));
endmodule
