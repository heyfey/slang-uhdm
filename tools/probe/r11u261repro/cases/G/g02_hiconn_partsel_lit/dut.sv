// § pselConnArrPathName261
module leaf (input logic [9:0] addr_i, output logic o);
  assign o = ^addr_i;
endmodule
module core (input logic [15:0] ma, output logic o);
  leaf i_flash (.addr_i(ma[11:2]), .o(o));
endmodule
module top;
  logic [15:0] a; logic o;
  core u (.ma(a), .o(o));
endmodule
