// § tdKeyKeepsUnresolved176v
module dut(output pa::u_t a, b);
  import pa::*;
  task automatic q(output u_t v);
    v = '1;
  endtask
  initial begin q(a); pb::t(b); end
endmodule
