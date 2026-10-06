// § genIfacePortActualInst263
interface bif #(parameter int AW = 16, parameter int BW = 32);
  logic valid;
  logic [AW-1:0] addr;
  modport master(output valid, output addr);
endinterface
interface wrap_if(bif.master p);
  logic seen;
  assign seen = p.valid;
endinterface
module blk(bif.master b15);
  if (1) begin : g
    wrap_if w(.p(b15));
  end
endmodule
module top;
  bif #(8, 32) b();
  blk u_blk(.b15(b));
endmodule
