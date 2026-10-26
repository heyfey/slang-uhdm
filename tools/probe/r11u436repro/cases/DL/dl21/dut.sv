// § genClsNoDefRangeSyntax436
class C #(int N);
  task t();
    begin
      logic [N-1:0] x;
      x = 0;
    end
  endtask
  function int g();
    bit [N:0] y;
    return y;
  endfunction
endclass
module top;
endmodule
