// § unitDynArrTd249
typedef logic [3:0] q_t[$];
module top;
  q_t q; int n;
  initial begin q.push_back(4'h1); n = q.size(); q[0] = 4'h2; end
endmodule
