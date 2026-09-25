package p;
  localparam logic [07:00] K = 8'h5a;
endpackage
module top (output logic [7:0] o);
  assign o = p::K;
endmodule
