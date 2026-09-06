// r10v167 arm C - the SAME faces in OTHER HOMES: module, interface, program,
// compilation unit; 1 and 2 and 3 instances of the module home.
function automatic int uf167(int a, int b = 2, int c = 5);
  return a + b + c;
endfunction

interface if167;
  int q;
  function int fi167(int a, int b = 3, int c = 4);
    return a + b + c;
  endfunction
  task ti167(int a, int b = 6);
    q = a + b;
  endtask
  class shI167 #(type T167 = int);
    int r;
    task goI();
      r = fi167(1);
      r = fi167(T167::nm167);
      r = fi167(.a(T167::nm167), .c(9));
      ti167(T167::nm167);
      r = uf167(T167::nm167);
    endtask
  endclass
endinterface

module m167 #(parameter int P = 1) (input logic clk);
  int r;
  function int fm167(int a, int b = 11, int c = 12);
    return a + b + c + P;
  endfunction
  task tm167(int a, int b = 13);
    r = a + b;
  endtask
  class shM167 #(type T167 = int);
    int rr;
    task goM();
      rr = fm167(1);
      rr = fm167(T167::nm167);
      rr = fm167(.a(T167::nm167), .c(9));
      rr = fm167(.c(9), .a(T167::nm167));
      tm167(T167::nm167);
      rr = uf167(T167::nm167);
      rr = fm167(T167::nm167, 2, );
    endtask
  endclass
endmodule

program pg167;
  int r;
  function int fp167(int a, int b = 21, int c = 22);
    return a + b + c;
  endfunction
  class shP167 #(type T167 = int);
    int rr;
    task goP();
      rr = fp167(1);
      rr = fp167(T167::nm167);
      rr = fp167(.a(T167::nm167), .c(9));
    endtask
  endclass
endprogram

module top167 (input logic clk);
  if167 iv();
  m167 #(.P(1)) u1 (.clk(clk));
  m167 #(.P(2)) u2 (.clk(clk));
  m167 #(.P(3)) u3 (.clk(clk));
endmodule
