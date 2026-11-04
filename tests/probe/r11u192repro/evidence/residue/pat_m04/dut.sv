module top #(parameter int W = 4) (output logic [W-1:0] o);
  localparam type s_t = struct packed { logic [W-1:0] a; logic [W-1:0] b; };
  localparam s_t P = '{a: (W'(1) << (W - 1)) | W'(1), b: W'(3)};
  assign o = P.a;
endmodule
