// § unpackedDimBasedLitKept454
interface ifc;
  logic [7:0] mem [16'h0010:16'h0013];
  task automatic clr();
    logic tl [2'd1:0];
    tl[0] = 0;
    mem[16] <= 0;
  endtask
endinterface
module top;
  ifc i();
  logic o [1'b0:1'b1];
  assign o[0] = i.mem[16][0];
  assign o[1] = 1'b0;
endmodule
