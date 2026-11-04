// § genLocalEnumConstShared184: a generate-block enum read in a function body, an initial block and a case inside the block
module dut #(parameter bit P = 1'b1) (input logic clk, input logic [1:0] a, output logic [1:0] y);
  if (P) begin : g
    typedef enum logic [1:0] {S0 = 2'd1, S1 = 2'd2, S2} st_e;
    st_e q;
    function automatic logic isz(logic [1:0] s);
      return s == S0;
    endfunction
    initial q = S2;
    always_ff @(posedge clk) begin
      unique case (a)
        2'd0: q <= S0;
        2'd1: q <= S1;
        default: q <= S2;
      endcase
    end
    assign y = q;
  end
endmodule
