// § genLocalEnumConstShared184: an enum and a variable of it declared in a generate-for body; the body's always_comb and a nested block's always_ff read the constants
module top (input logic clk, input logic [3:0] a, output logic [3:0] y);
  for (genvar i = 0; i < 2; i++) begin : lane
    typedef enum logic [1:0] {LO, MID, HI} lvl_e;
    lvl_e cur;
    always_comb begin
      if (a[i]) cur = HI; else cur = LO;
    end
    if (i == 0) begin : first
      always_ff @(posedge clk) y[i] <= (cur == HI);
    end else begin : rest
      always_ff @(posedge clk) y[i] <= (cur != MID);
    end
  end
endmodule
