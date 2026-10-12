// § defNetClassArrTsDimEnd293
// A program class handle queue.
class C; int x; endclass
program prg;
  C q [$];
  initial q.push_back(null);
endprogram
module top;
  prg u_p ();
endmodule
