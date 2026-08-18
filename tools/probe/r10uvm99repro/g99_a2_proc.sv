// r10uvm99 arm a2: `inside` in a TASK statement, an ALWAYS block, a
// continuous assign, a ternary, a return expression, a while condition.
module omicron99 (input logic [7:0] pin99, output logic flg99);
  logic hit99;
  int reg99;
  assign flg99 = pin99 inside {[8'd3:8'd12]};
  wire wire99 = pin99 inside {8'd1, [8'd5:8'd6]};
  always_comb hit99 = pin99 inside {[8'd2:8'd4]};
  always @(*) begin
    if (pin99 inside {[8'd0:8'd7]}) reg99 = 1; else reg99 = 0;
  end
  task automatic tsk99(int uv);
    if (uv inside {[3:5]}) reg99 = uv;
    while (uv inside {[0:2]}) uv = uv + 1;
  endtask
  function automatic int fn99(int uv);
    return (uv inside {[1:4]}) ? 10 : 20;
  endfunction
  initial begin
    reg99 = 0;
    if (pin99 inside {[8'd9:8'd10]}) reg99 = 5;
  end
endmodule
