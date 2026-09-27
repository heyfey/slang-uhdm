// § genLocalEnumConstShared184: the block enum read in a block function, a named begin with its own variable, and a block localparam of the enum
module dut #(parameter bit P = 1'b1) (input logic clk, output logic [1:0] y, output logic z);
  if (P) begin : g
    typedef enum logic [1:0] {B0, B1, B2} b_e;
    localparam b_e LP = B2;
    function automatic logic isb1(b_e v);
      return v == B1;
    endfunction
    b_e q;
    always_ff @(posedge clk) begin : nb
      b_e t;
      t = B0;
      q <= (t == B0) ? LP : B1;
    end
    always_comb begin
      y = (q == LP) ? 2'd1 : 2'd0;
      z = isb1(q);
    end
  end
endmodule
