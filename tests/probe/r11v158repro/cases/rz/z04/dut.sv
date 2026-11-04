// § methodRandomizeCallSpan158
class pkt; rand bit [3:0] a; endclass
class holder; pkt q[2]; endclass
module dut;
  holder h; int ok;
  initial begin
    h = new; h.q[0] = new;
    ok = h.q[0].randomize();
  end
endmodule
