module mm import pa::*; (input logic [4:0] i, output logic o);
  s_t nn [2];
  assign nn[0] = i;
  assign o = nn[0].y;
endmodule
