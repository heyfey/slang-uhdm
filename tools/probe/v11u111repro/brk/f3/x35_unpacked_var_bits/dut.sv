package q2;
  typedef logic ut_e;
  typedef ut_e [0:3] row_t;
endpackage
module dut (input logic [3:0] i, output logic [3:0] o, output int n);
  q2::row_t arr [2];
  assign arr[0] = i;
  assign arr[1] = ~i;
  assign o = arr[0] ^ arr[1];
  assign n = $bits(q2::row_t);
endmodule
