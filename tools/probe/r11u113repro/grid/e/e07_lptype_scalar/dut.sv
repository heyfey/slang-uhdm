module m(output logic [3:0] o);
  localparam type T = struct packed { enum logic [1:0] {A, B, C} e; logic [1:0] b; };
  T x;
  assign x = '0;
  assign o = x;
endmodule
