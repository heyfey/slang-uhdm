interface if223p();
   logic sig223p;
   initial sig223p = 0;
   always_comb begin end
endinterface

interface if223q();
   logic sig223q;
   initial sig223q = 0;
endinterface

module top223p;
   if223q u_q223();
endmodule
