// § timeModVarIsNet406
module top(output logic [63:0] o);
  time t;
  assign t = 64'd5;
  assign o = t;
endmodule
