// § genIfacePortActualInst263
interface bif #(parameter int AW = 16, parameter int BW = 32);
  logic valid;
  logic [AW-1:0] addr;
  modport master(output valid, output addr);
endinterface
module ext(bif.master bus_if);
  assign bus_if.valid = 1'b1;
endmodule
module blk(bif.master b15);
  for (genvar k = 0; k < 2; k++) begin : g
    if (k == 0) begin : h
      ext u(b15);
    end
  end
endmodule
module top;
  bif #(8, 32) bb();
  blk u_blk(.b15(bb));
endmodule
