// r10uvm100 arm a3 -- the SAME delays written through a MACRO, exactly the
// uvm-1.2 `uvm_delay(TIME) shape, with an identifier argument and with an
// expression argument, in a module, a class task and a fork body.
`define D3(T) #(T);
`define E3(T) #T;
module m3a;
  parameter Tp3 = 3;
  int a3;
  task automatic tk3(int t);
    `D3(t)
    a3 = 1;
    `D3(t + 1)
    a3 = 2;
    `E3(t)
    a3 = 3;
    `D3(4)
    a3 = 4;
  endtask
  initial begin
    `D3(Tp3)
    a3 = 5;
    fork begin
      `D3(Tp3)
      a3 = 6;
    end join_none
  end
endmodule
