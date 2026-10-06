// § genIfacePortActualInst263
interface bif #(parameter int AW = 8);
  logic valid;
  logic [AW-1:0] addr;
  modport master(output valid, output addr);
  modport slave(input valid, input addr);
endinterface
module ext(bif.master bus_if);
  assign bus_if.valid = 1'b1;
  assign bus_if.addr = '0;
endmodule
module blk #(parameter int K = 2) (bif.master b15);
  for (genvar i = 0; i < K; i++) begin : g
    if (i == 0) begin : h
      ext u(.bus_if(b15));
    end
  end
endmodule
module top;
  bif #(8) b();
  blk #(1) u_blk(.b15(b));
  bif #(8) c();
  blk #(1) u_blk2(.b15(c));
endmodule
