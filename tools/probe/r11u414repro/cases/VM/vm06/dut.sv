// § varInitUintMask414
module top();
initial begin
  logic a = 3;
  logic [1:0] b = 6;
end
function int f();
  logic [1:0] x = 7;
  return x;
endfunction
endmodule
