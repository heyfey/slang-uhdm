// § streamBraceInMacroBody246
`define ASG(L,R) L = R;
module top;
  logic [31:0] y, z;
  logic [15:0] a, b;
  initial begin
    `ASG(z, {<<8{y}})
    `ASG({>>{a,b}}, y)
  end
  class c;
    int arr[];
    bit [63:0] bits;
    function void f();
      `ASG(bits, {<< int {arr}})
    endfunction
  endclass
endmodule
