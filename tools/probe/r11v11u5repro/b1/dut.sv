`define PRIM_STRINGIFY(__x) `"__x`"
`define ASSERT_ERROR(__name)                                                             \
  $error("%0t: (%0s:%0d) [%m] [ASSERT FAILED] %0s", $time, `__FILE__, `__LINE__,         \
         `PRIM_STRINGIFY(__name));                                                       \

module top(input logic clk, input logic a);
  always_ff @(posedge clk) begin
    if (!a) begin
      `ASSERT_ERROR(MyName)
    end
  end
endmodule
