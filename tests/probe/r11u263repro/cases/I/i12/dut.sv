// § genIfacePortActualInst263
interface bif #(parameter int AW = 16, parameter int BW = 32);
  logic valid;
  logic [AW-1:0] addr;
  modport master(output valid, output addr);
endinterface
module ext(bif.master bus_if);
  assign bus_if.valid = 1'b1;
endmodule
module blk(bif.master b15, bif.master b16);
  if (1) begin : g
    ext u0(.bus_if(b15));
    ext u1(.bus_if(b16));
  end
  ext u2(.bus_if(b16));
endmodule
module top;
  bif #(8, 32) b15();
  bif #(8, 32) b16();
  blk u_blk(.b15(b15), .b16(b16));
endmodule
