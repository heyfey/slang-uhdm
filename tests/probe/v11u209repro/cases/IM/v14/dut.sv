// § portConnOpLeafChain209: an interface array element member inside a connection operation
interface tif;
  logic trn;
endinterface
module inner (input logic b, output logic o);
  assign o = b;
endmodule
module top (input logic t0, input logic t1, input logic t, output logic o);
  tif s [2] ();
  assign s[0].trn = t0;
  assign s[1].trn = t1;
  inner u (.b(s[1].trn & t), .o(o));
endmodule
