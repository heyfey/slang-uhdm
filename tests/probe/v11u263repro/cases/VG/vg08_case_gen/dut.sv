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
module blk(bif.master b15);
  case (1)
    1: begin : c1
      ext u(.bus_if(b15));
    end
    default: begin : cd
    end
  endcase
endmodule
module top;
  bif #(8) b();
  blk u_blk(.b15(b));
endmodule
