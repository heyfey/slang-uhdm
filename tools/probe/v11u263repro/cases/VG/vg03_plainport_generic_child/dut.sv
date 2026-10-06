// § genIfacePortActualInst263
interface bif #(parameter int AW = 8);
  logic valid;
  logic [AW-1:0] addr;
  modport master(output valid, output addr);
  modport slave(input valid, input addr);
endinterface
module gext(interface bus_if);
  assign bus_if.valid = 1'b1;
endmodule
module blk(bif b15);
  if (1) begin : g
    gext u(.bus_if(b15));
  end
endmodule
module top;
  bif #(8) b();
  blk u_blk(.b15(b));
endmodule
