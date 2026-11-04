// § genIfacePortActualInst263
interface bif #(parameter int AW = 16, parameter int BW = 32);
  logic valid;
  logic [AW-1:0] addr;
  modport master(output valid, output addr);
endinterface
program ext(bif.master bus_if);
  initial bus_if.valid = 1'b1;
endprogram
module blk(bif.master b15);
  if (1) begin : g
    ext u(.bus_if(b15));
  end
endmodule
module top;
  bif #(8, 32) b();
  blk u_blk(.b15(b));
endmodule
