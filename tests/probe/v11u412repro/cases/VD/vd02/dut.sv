// § tfDeclOnlyBodyBegin412
module top(input logic clk, output logic [3:0] o);
  function void f();
    int x;
  endfunction
  function automatic int g();
    int a;
    int b;
  endfunction
  always_ff @(posedge clk) begin
    f();
    o <= g();
  end
endmodule
