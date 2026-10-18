// § castSizeSubrLocalBind401
class C;
  function logic [7:0] f();
    localparam int W = 3;
    return W'(5);
  endfunction
endclass
module top;
  logic [7:0] y;
  task t();
    localparam int K = 2;
    y = K'(7);
  endtask
  initial t();
endmodule
