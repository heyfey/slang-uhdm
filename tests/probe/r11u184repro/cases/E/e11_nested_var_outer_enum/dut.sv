// § genLocalEnumConstShared184: a nested generate block declaring a variable of the outer block's enum, read in its process
module dut #(parameter bit P = 1'b1, parameter bit Q = 1'b1) (input logic clk, output logic [1:0] y);
  if (P) begin : g
    typedef enum logic [1:0] {S0, S1, S2} st_e;
    if (Q) begin : h
      st_e r;
      always_ff @(posedge clk) r <= (r == S0) ? S1 : S2;
      assign y = r;
    end
  end
endmodule
