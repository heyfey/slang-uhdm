module child #(parameter int W = 2, localparam type d_t = logic [W-1:0]) (input d_t a, output d_t b);
  assign b = ~a;
endmodule
module dut (input logic [4:0] a, output logic [4:0] b);
  child #(.W(5)) u (.a(a), .b(b));
endmodule
