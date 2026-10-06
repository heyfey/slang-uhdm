// § genIfacePortActualInst263
interface bif #(parameter int AW = 8);
  logic valid;
  logic [AW-1:0] addr;
  modport master(output valid, output addr);
endinterface
module ext(bif.master bus_if);
  assign bus_if.valid = 1'b1;
endmodule
module blk(bif.master b15);
  if (1) begin : g
    ext u(.bus_if(b15));
  end
endmodule
module top;
  bif #(8) b[2]();
  blk u_blk0(.b15(b[0]));
  blk u_blk1(.b15(b[1]));
endmodule
