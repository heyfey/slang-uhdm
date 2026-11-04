// § clsArrPatBasedLitElemW460 (queues, module concatenation)
class C;
  int q[$] = '{'h1, 'h2};
  int q2[$] = {'h5, 'h6};
endclass
module top;
  int mq[$] = {'h1, 'h2};
  int md[] = {'h3, 'b110};
  initial begin C c; c = new; end
endmodule
